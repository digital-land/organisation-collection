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

ifeq ($(DATASET_DIR),)
DATASET_DIR=dataset/
endif

define run-pipeline =
	mkdir -p $(@D) $(ISSUE_DIR)$(notdir $(@D))
	digital-land --pipeline-name $(notdir $(@D)) pipeline --issue-dir $(ISSUE_DIR)$(notdir $(@D)) $(PIPELINE_FLAGS) $< $@
endef

define build-dataset =
	mkdir -p $(@D)
	csvstack -z $(shell python -c 'print(__import__("sys").maxsize)') --filenames -n resource $(^) < /dev/null | sed 's/^\([^\.]*\).csv,/\1,/' > $@
endef

collection:: collection/pipeline.mk

-include collection/pipeline.mk

collection/pipeline.mk: collection/resource.csv collection/source.csv
	digital-land collection-pipeline-makerules > collection/pipeline.mk

# restart the make process to pick-up collected resource files
second-pass::
	@$(MAKE) --no-print-directory transformed dataset

init::
	pip install csvkit

clobber::
	rm -rf $(TRANSFORMED_DIR) $(ISSUE_DIR) $(DATASET_DIR)

clean::
	rm -rf ./var

# local copies of the organisation dataset needed by harmonise
init::
	@mkdir -p $(CACHE_DIR)
	curl -qs "https://raw.githubusercontent.com/digital-land/organisation-dataset/main/collection/organisation.csv" > $(CACHE_DIR)organisation.csv

makerules::
	curl -qsL '$(SOURCE_URL)/makerules/main/pipeline.mk' > makerules/pipeline.mk

commit-dataset::
	git add transformed issue dataset
	git diff --quiet && git diff --staged --quiet || (git commit -m "Data $(shell date +%F)"; git push origin $(BRANCH))
