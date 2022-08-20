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

ifeq ($(FLATTENED_DIR),)
FLATTENED_DIR=flattened/
endif

ifeq ($(DATASET_DIRS),)
DATASET_DIRS=\
	$(TRANSFORMED_DIR)\
	$(COLUMN_FIELD_DIR)\
	$(DATASET_RESOURCE_DIR)\
	$(ISSUE_DIR)\
	$(DATASET_DIR)\
	$(FLATTENED_DIR)
endif

define run-pipeline
	mkdir -p $(@D) $(ISSUE_DIR)$(notdir $(@D)) $(COLUMN_FIELD_DIR)$(notdir $(@D)) $(DATASET_RESOURCE_DIR)$(notdir $(@D))
	digital-land --dataset $(notdir $(@D)) $(DIGITAL_LAND_FLAGS) pipeline $(1) --issue-dir $(ISSUE_DIR)$(notdir $(@D)) --column-field-dir $(COLUMN_FIELD_DIR)$(notdir $(@D)) --dataset-resource-dir $(DATASET_RESOURCE_DIR)$(notdir $(@D)) $(PIPELINE_FLAGS) $< $@
endef

define build-dataset =
	mkdir -p $(@D)
	time digital-land --dataset $(notdir $(basename $@)) dataset-create --output-path $(basename $@).sqlite3 $(^)
	time datasette inspect $(basename $@).sqlite3 --inspect-file=$(basename $@).sqlite3.json
	time digital-land --dataset $(notdir $(basename $@)) dataset-entries $(basename $@).sqlite3 $@
	mkdir -p $(FLATTENED_DIR)
	time digital-land --dataset $(notdir $(basename $@)) dataset-entries-flattened $@ $(FLATTENED_DIR)
	md5sum $@ $(basename $@).sqlite3
	csvstack $(wildcard $(ISSUE_DIR)/$(notdir $(basename $@))/*.csv) > $(basename $@)-issue.csv
endef

collection::
	digital-land collection-pipeline-makerules > collection/pipeline.mk

-include collection/pipeline.mk

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
	pyproj sync --file uk_os_OSTN15_NTv2_OSGBtoETRS.tif -v


clobber::
	rm -rf $(DATASET_DIRS)

clean::
	rm -rf ./var

# local copy of the organisation dataset
init::
	@mkdir -p $(CACHE_DIR)
	curl -qfs "https://raw.githubusercontent.com/digital-land/organisation-dataset/main/collection/organisation.csv" > $(CACHE_DIR)organisation.csv

makerules::
	curl -qfsL '$(SOURCE_URL)/makerules/main/pipeline.mk' > makerules/pipeline.mk

save-transformed::
	aws s3 sync $(TRANSFORMED_DIR) s3://$(COLLECTION_DATASET_BUCKET_NAME)/$(REPOSITORY)/$(TRANSFORMED_DIR) --no-progress
	aws s3 sync $(ISSUE_DIR) s3://$(COLLECTION_DATASET_BUCKET_NAME)/$(REPOSITORY)/$(ISSUE_DIR) --no-progress
	aws s3 sync $(COLUMN_FIELD_DIR) s3://$(COLLECTION_DATASET_BUCKET_NAME)/$(REPOSITORY)/$(COLUMN_FIELD_DIR) --no-progress
	aws s3 sync $(DATASET_RESOURCE_DIR) s3://$(COLLECTION_DATASET_BUCKET_NAME)/$(REPOSITORY)/$(DATASET_RESOURCE_DIR) --no-progress

save-dataset::
	aws s3 sync $(DATASET_DIR) s3://$(COLLECTION_DATASET_BUCKET_NAME)/$(REPOSITORY)/$(DATASET_DIR) --no-progress
	@mkdir -p $(FLATTENED_DIR)
	aws s3 sync $(FLATTENED_DIR) s3://$(HOISTED_COLLECTION_DATASET_BUCKET_NAME)/data/ --no-progress

# convert an individual resource
# .. this assumes conversion is the same for every dataset, but it may not be soon
var/converted/%.csv: collection/resource/%
	mkdir -p var/converted/
	digital-land convert $<

transformed::
	@mkdir -p $(TRANSFORMED_DIR)

metadata.json:
	echo "{}" > $@

datasette:	metadata.json
	datasette serve $(DATASET_DIR)/*.sqlite3 \
	--setting sql_time_limit_ms 5000 \
	--load-extension $(SPATIALITE_EXTENSION) \
	--metadata metadata.json
