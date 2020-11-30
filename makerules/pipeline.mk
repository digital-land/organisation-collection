.PHONY: \
	convert\
	normalise\
	harmonise\
	transform\
	dataset\
	commit-dataset

# produced dataset
ifeq ($(DATASET_DIR),)
DATASET_DIR=dataset/
endif

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
CACHE_DIR=var/cache
endif

# restart the make process to pick-up collected resource files
second-pass::
	@$(MAKE) --no-print-directory dataset


#
#  convert resources into CSV
#
CONVERTED_DIR=var/converted/
CONVERTED_FILES := $(addsuffix .csv,$(subst $(RESOURCE_DIR),$(CONVERTED_DIR),$(RESOURCE_FILES)))

$(CONVERTED_DIR)%.csv: $(RESOURCE_DIR)%
	@mkdir -p $(CONVERTED_DIR)
	digital-land convert  $< $@

# resources which can't be converted automatically
FIXED_FILES:=$(wildcard $(FIXED_DIR)*.csv)
FIXED_CONVERTED_FILES:=$(subst $(FIXED_DIR),$(CONVERTED_DIR),$(FIXED_FILES))

$(FIXED_CONVERTED_FILES):
	@mkdir -p $(CONVERTED_DIR)
	digital-land convert $(subst $(CONVERTED_DIR),$(FIXED_DIR),$@) $@

convert:: $(CONVERTED_FILES)
	@:


#
#  normalise CSV whitespace
#
NORMALISED_DIR=var/normalised/
NORMALISED_FILES := $(subst $(CONVERTED_DIR),$(NORMALISED_DIR),$(CONVERTED_FILES))

$(NORMALISED_DIR)%.csv: $(CONVERTED_DIR)%.csv
	@mkdir -p $(NORMALISED_DIR)
	digital-land --pipeline-name $(PIPELINE_NAME) normalise $< $@

normalise:: $(NORMALISED_FILES)
	@:


#
#  map CSV columns
#
MAPPED_DIR=var/mapped/
MAPPED_FILES     := $(subst $(CONVERTED_DIR),$(MAPPED_DIR),$(CONVERTED_FILES))

$(MAPPED_DIR)%.csv: $(NORMALISED_DIR)%.csv $(PIPELINE_DIR)
	@mkdir -p $(MAPPED_DIR)
	digital-land --pipeline-name $(PIPELINE_NAME) map $< $@

map:: $(MAPPED_FILES)
	@:


#
#  harmonise CSV values
#
HARMONISED_DIR=var/harmonised/
HARMONISED_FILES := $(subst $(CONVERTED_DIR),$(HARMONISED_DIR),$(CONVERTED_FILES))

HARMONISE_DATA=\
	$(CACHE_DIR)/organisation.csv

# a file of issues is produced for each resource
ISSUE_DIR=issue/
ISSUE_FILES := $(subst $(CONVERTED_DIR),$(ISSUE_DIR),$(CONVERTED_FILES))

$(HARMONISED_DIR)%.csv: $(MAPPED_DIR)%.csv $(HARMONISE_DATA)
	@mkdir -p $(HARMONISED_DIR) $(ISSUE_DIR)
	digital-land --pipeline-name $(PIPELINE_NAME) harmonise --use-patch-callback --issue-path $(ISSUE_DIR) $< $@

harmonise:: $(HARMONISED_FILES)
	@:


#
#  transform older fields into the latest model
#
TRANSFORMED_DIR=var/transformed/
TRANSFORMED_FILES:= $(subst $(CONVERTED_DIR),$(TRANSFORMED_DIR),$(CONVERTED_FILES))

$(TRANSFORMED_DIR)%.csv: $(HARMONISED_DIR)%.csv
	@mkdir -p $(TRANSFORMED_DIR)
	digital-land --pipeline-name $(PIPELINE_NAME) transform $< $@

transform:: $(TRANSFORMED_FILES)
	@mkdir -p $(TRANSFORMED_DIR)
	@:


#
#  transform collected or fixed resources in a single pipeline
#
PIPELINED_DIR=transformed/
PIPELINED_FILES := $(addsuffix .csv,$(subst $(RESOURCE_DIR),$(PIPELINED_DIR),$(RESOURCE_FILES)))

$(PIPELINED_DIR)%.csv: $(RESOURCE_DIR)%
	@mkdir -p $(PIPELINED_DIR)
	digital-land --pipeline-name $(PIPELINE_NAME) pipeline --issue-path issue/ --use-patch-callback $< $@

# fixed resources which can't be converted automatically
FIXED_FILES:=$(wildcard $(FIXED_DIR)*.csv)
FIXED_PIPELINED_FILES:=$(subst $(FIXED_DIR),$(PIPELINED_DIR),$(FIXED_FILES))

$(FIXED_PIPELINED_FILES):
	@mkdir -p $(PIPELINED_DIR)
	digital-land --pipeline-name $(PIPELINE_NAME) pipeline --issue-path issue/ --use-patch-callback $(subst $(PIPELINED_DIR),$(FIXED_DIR),$@) $@

pipeline:: $(PIPELINED_FILES)
	@:


#
#  national dataset from transformed resources
#  - temporarily uses csvkit to concatenate the files
#
NATIONAL_DATASET=$(DATASET_DIR)/$(PIPELINE_NAME).csv

init::
	pip install csvkit

$(NATIONAL_DATASET): $(PIPELINED_FILES)
	@mkdir -p $(DATASET_DIR)
	csvstack -z $(shell python -c 'print(__import__("sys").maxsize)') --filenames -n resource $(PIPELINED_FILES) | sed 's/^\([^\.]*\).csv,/\1,/' > $@

dataset:: $(NATIONAL_DATASET)


# local copies of datasets
$(CACHE_DIR)/organisation.csv:
	@mkdir -p $(CACHE_DIR)
	curl -qs "https://raw.githubusercontent.com/digital-land/organisation-dataset/master/collection/organisation.csv" > $@


makerules::
	curl -qsL '$(SOURCE_URL)/makerules/master/pipeline.mk' > makerules/pipeline.mk

commit-dataset::
	git add transformed issue dataset
	git diff --quiet && git diff --staged --quiet || (git commit -m "Data $(shell date +%F)"; git push origin $(BRANCH))
