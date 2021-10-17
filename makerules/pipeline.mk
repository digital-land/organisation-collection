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
	mkdir -p $(@D) $(ISSUE_DIR)$(notdir $(@D))
	digital-land --pipeline-name $(notdir $(@D)) $(DIGITAL_LAND_FLAGS) pipeline --issue-dir $(ISSUE_DIR)$(notdir $(@D)) $(PIPELINE_FLAGS) $< $@
endef

define build-dataset =
	mkdir -p $(@D)
	time digital-land --pipeline-name $(notdir $(basename $@)) load-entries --output-path $(basename $@).sqlite3 $(^)
	time digital-land --pipeline-name $(notdir $(basename $@)) build-dataset $(basename $@).sqlite3 $@
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
	aws s3 sync s3://collection-dataset/$(REPOSITORY)/$(RESOURCE_DIR) $(RESOURCE_DIR)
	aws s3 sync s3://collection-dataset/$(REPOSITORY)/$(ISSUE_DIR) $(ISSUE_DIR)
	aws s3 sync s3://collection-dataset/$(REPOSITORY)/$(TRANSFORMED_DIR) $(TRANSFORMED_DIR)
	aws s3 sync s3://collection-dataset/$(REPOSITORY)/$(DATASET_DIR) $(DATASET_DIR)
	
push-collection-s3::
	aws s3 sync $(RESOURCE_DIR) s3://collection-dataset/$(REPOSITORY)/$(RESOURCE_DIR)
	aws s3 cp $(COLLECTION_DIR)/log.csv s3://collection-dataset/$(REPOSITORY)/$(COLLECTION_DIR)
	aws s3 cp $(COLLECTION_DIR)/resource.csv s3://collection-dataset/$(REPOSITORY)/$(COLLECTION_DIR)
	aws s3 cp $(COLLECTION_DIR)/source.csv s3://collection-dataset/$(REPOSITORY)/$(COLLECTION_DIR)
	aws s3 cp $(COLLECTION_DIR)/endpoint.csv s3://collection-dataset/$(REPOSITORY)/$(COLLECTION_DIR)

push-dataset-s3::
	@mkdir -p $(TRANSFORMED_DIR)
	aws s3 sync $(TRANSFORMED_DIR) s3://collection-dataset/$(REPOSITORY)/$(TRANSFORMED_DIR)
	@mkdir -p $(ISSUE_DIR)
	aws s3 sync $(ISSUE_DIR) s3://collection-dataset/$(REPOSITORY)/$(ISSUE_DIR)
	@mkdir -p $(DATASET_DIR)
	aws s3 sync $(DATASET_DIR) s3://collection-dataset/$(REPOSITORY)/$(DATASET_DIR)
