.PHONY: \
	transformed\
	dataset\
	commit-dataset

# data sources
# collected resources
ifeq ($(COLLECTION_DIR),)
COLLECTION_DIR=collection/
endif

ifeq ($(RESOURCE_DIR),)
RESOURCE_DIR=$(COLLECTION_DIR)resource/
endif

ifeq ($(RESOURCE_FILES),)
RESOURCE_FILES:=$(wildcard $(RESOURCE_DIR)*)
endif

ifeq ($(FIXED_DIR),)
FIXED_DIR=fixed/
endif

ifeq ($(CACHE_DIR),)
CACHE_DIR=var/cache/
endif

ifeq ($(HARMONISED_DIR),)
ifneq ($(PIPELINE_FLAGS),)
HARMONISED_DIR=harmonised/
endif
endif

ifeq ($(TRANSFORMED_DIR),)
TRANSFORMED_DIR=transformed/
endif

ifeq ($(ISSUE_DIR),)
ISSUE_DIR=issue/
endif

ifeq ($(COLUMN_FIELD_DIR),)
COLUMN_FIELD_DIR=var/column-field/
endif

ifeq ($(DATASET_RESOURCE_DIR),)
DATASET_RESOURCE_DIR=var/dataset-resource/
endif

ifeq ($(DATASET_DIR),)
DATASET_DIR=dataset/
endif

ifeq ($(DATASET_DIRS),)
DATASET_DIRS=\
	$(HARMONISED_DIR)\
	$(TRANSFORMED_DIR)\
	$(ISSUE_DIR)\
	$(DATASET_DIR)
endif

define run-pipeline =
	mkdir -p $(@D) $(ISSUE_DIR)$(notdir $(@D)) $(COLUMN_FIELD_DIR)$(notdir $(@D)) $(DATASET_RESOURCE_DIR)$(notdir $(@D))
	digital-land --dataset $(notdir $(@D)) $(DIGITAL_LAND_FLAGS) pipeline --issue-dir $(ISSUE_DIR)$(notdir $(@D)) --column-field-dir $(COLUMN_FIELD_DIR)$(notdir $(@D)) --dataset-resource-dir $(DATASET_RESOURCE_DIR)$(notdir $(@D)) $(PIPELINE_FLAGS) $< $@
endef

define build-dataset =
	mkdir -p $(@D)
	time digital-land --dataset $(notdir $(basename $@)) dataset-create --output-path $(basename $@).sqlite3 $(^)
	time digital-land --dataset $(notdir $(basename $@)) dataset-entries $(basename $@).sqlite3 $@
	md5sum $@ $(basename $@).sqlite3
	csvstack $(wildcard $(ISSUE_DIR)/$(notdir $(basename $@))/*.csv) > $(basename $@)-issue.csv
endef

collection:: collection/pipeline.mk

-include collection/pipeline.mk

collection/pipeline.mk: collection/resource.csv collection/source.csv
	digital-land collection-pipeline-makerules > collection/pipeline.mk

# restart the make process to pick-up collected resource files
second-pass::
	@$(MAKE) --no-print-directory transformed dataset

GDAL := $(shell command -v ogr2ogr 2> /dev/null)
UNAME := $(shell uname)

init::
	pip install csvkit
ifndef GDAL
ifeq ($(UNAME),Darwin)
$(error GDAL tools not found in PATH)
endif
	sudo apt-get install gdal-bin
endif

clobber::
	rm -rf $(TRANSFORMED_DIR) $(ISSUE_DIR) $(DATASET_DIR)

clean::
	rm -rf ./var

# local copies of the organisation dataset needed by harmonise
init::
	@mkdir -p $(CACHE_DIR)
	curl -qfs "https://raw.githubusercontent.com/digital-land/organisation-dataset/main/collection/organisation.csv" > $(CACHE_DIR)organisation.csv

makerules::
	curl -qfsL '$(SOURCE_URL)/makerules/main/pipeline.mk' > makerules/pipeline.mk

commit-dataset::
	mkdir -p $(DATASET_DIRS)
	git add $(DATASET_DIRS)
	git diff --quiet && git diff --staged --quiet || (git commit -m "Data $(shell date +%F)"; git push origin $(BRANCH))

fetch-s3::
	aws s3 sync s3://$(COLLECTION_DATASET_BUCKET_NAME)/$(REPOSITORY)/$(RESOURCE_DIR) $(RESOURCE_DIR) --no-progress

fetch-transformed-s3::
	#aws s3 sync s3://$(COLLECTION_DATASET_BUCKET_NAME)/$(REPOSITORY)/$(ISSUE_DIR) $(ISSUE_DIR) --no-progress
	#aws s3 sync s3://$(COLLECTION_DATASET_BUCKET_NAME)/$(REPOSITORY)/$(TRANSFORMED_DIR) $(TRANSFORMED_DIR) --no-progress
	#aws s3 sync s3://$(COLLECTION_DATASET_BUCKET_NAME)/$(REPOSITORY)/$(DATASET_DIR) $(DATASET_DIR) --no-progress

push-collection-s3::
	aws s3 sync $(RESOURCE_DIR) s3://$(COLLECTION_DATASET_BUCKET_NAME)/$(REPOSITORY)/$(RESOURCE_DIR) --no-progress
	aws s3 cp $(COLLECTION_DIR)/log.csv s3://$(COLLECTION_DATASET_BUCKET_NAME)/$(REPOSITORY)/$(COLLECTION_DIR) --no-progress
	aws s3 cp $(COLLECTION_DIR)/resource.csv s3://$(COLLECTION_DATASET_BUCKET_NAME)/$(REPOSITORY)/$(COLLECTION_DIR) --no-progress
	aws s3 cp $(COLLECTION_DIR)/source.csv s3://$(COLLECTION_DATASET_BUCKET_NAME)/$(REPOSITORY)/$(COLLECTION_DIR) --no-progress
	aws s3 cp $(COLLECTION_DIR)/endpoint.csv s3://$(COLLECTION_DATASET_BUCKET_NAME)/$(REPOSITORY)/$(COLLECTION_DIR) --no-progress

push-dataset-s3::
	@mkdir -p $(TRANSFORMED_DIR)
	aws s3 sync $(TRANSFORMED_DIR) s3://$(COLLECTION_DATASET_BUCKET_NAME)/$(REPOSITORY)/$(TRANSFORMED_DIR) --no-progress
	@mkdir -p $(ISSUE_DIR)
	aws s3 sync $(ISSUE_DIR) s3://$(COLLECTION_DATASET_BUCKET_NAME)/$(REPOSITORY)/$(ISSUE_DIR) --no-progress
	@mkdir -p $(DATASET_DIR)
	aws s3 sync $(DATASET_DIR) s3://$(COLLECTION_DATASET_BUCKET_NAME)/$(REPOSITORY)/$(DATASET_DIR) --no-progress

pipeline-run::
	aws batch submit-job --job-name $(REPOSITORY)-$(shell date '+%Y-%m-%d-%H-%M-%S') --job-queue dl-batch-queue --job-definition dl-batch-def --container-overrides '{"environment": [{"name":"BATCH_FILE_URL","value":"https://raw.githubusercontent.com/digital-land/docker-builds/main/pipeline_run.sh"}, {"name" : "REPOSITORY","value" : "$(REPOSITORY)"}]}'

var/converted/%.csv: collection/resource/%
	mkdir -p var/converted/
	digital-land convert $<


metadata.json:
	echo "{}" > $@

datasette:	metadata.json
	datasette serve $(DATASET_DIR)/*.sqlite3 \
	--setting sql_time_limit_ms 5000 \
	--load-extension $(SPATIALITE_EXTENSION) \
	--metadata metadata.json
