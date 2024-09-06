.PHONY: \
	collect\
	collection\
	commit-collection\
	clobber-today

ifeq ($(COLLECTION_CONFIG_URL),)
COLLECTION_CONFIG_URL=$(CONFIG_URL)collection/$(COLLECTION_NAME)/
endif

ifeq ($(COLLECTION_DIR),)
COLLECTION_DIR=collection/
endif

ifeq ($(RESOURCE_DIR),)
RESOURCE_DIR=$(COLLECTION_DIR)resource/
endif

ifeq ($(DATASTORE_URL),)
DATASTORE_URL=https://files.planning.data.gov.uk/
endif


# data sources
SOURCE_CSV=$(COLLECTION_DIR)source.csv
ENDPOINT_CSV=$(COLLECTION_DIR)endpoint.csv
OLD_RESOURCE_CSV=$(COLLECTION_DIR)old-resource.csv

ifeq ($(COLLECTION_CONFIG_FILES),)
COLLECTION_CONFIG_FILES=\
	$(SOURCE_CSV)\
	$(ENDPOINT_CSV)\
	$(OLD_RESOURCE_CSV)
endif

# collection log
LOG_DIR=$(COLLECTION_DIR)log/
LOG_FILES_TODAY:=$(LOG_DIR)$(shell date +%Y-%m-%d)/

# collection index
COLLECTION_INDEX=\
	$(COLLECTION_DIR)/log.csv\
	$(COLLECTION_DIR)/resource.csv

init::
	$(eval LOG_STATUS_CODE := $(shell curl -I -o /dev/null -s -w "%{http_code}" '$(DATASTORE_URL)$(REPOSITORY)/$(COLLECTION_DIR)log.csv'))
	$(eval RESOURCE_STATUS_CODE = $(shell curl -I -o /dev/null -s -w "%{http_code}" '$(DATASTORE_URL)$(REPOSITORY)/$(COLLECTION_DIR)resource.csv'))
	@if [ $(LOG_STATUS_CODE) -ne 403 ] && [ $(RESOURCE_STATUS_CODE) -ne 403 ]; then \
		echo 'Downloading log.csv and resource.csv'; \
		curl -qfsL '$(DATASTORE_URL)$(REPOSITORY)/$(COLLECTION_DIR)log.csv' > $(COLLECTION_DIR)log.csv; \
		curl -qfsL '$(DATASTORE_URL)$(REPOSITORY)/$(COLLECTION_DIR)resource.csv' > $(COLLECTION_DIR)resource.csv; \
	else \
		echo 'Unable to locate log.csv and resource.csv' ;\
	fi

first-pass:: collect

second-pass:: collection

collect:: $(COLLECTION_CONFIG_FILES)
	@mkdir -p $(RESOURCE_DIR)
	digital-land ${DIGITAL_LAND_OPTS} collect $(ENDPOINT_CSV) --collection-dir $(COLLECTION_DIR)

collection::
	digital-land ${DIGITAL_LAND_OPTS} collection-save-csv --collection-dir $(COLLECTION_DIR)

clobber-today::
	rm -rf $(LOG_FILES_TODAY) $(COLLECTION_INDEX)

makerules::
	curl -qfsL '$(SOURCE_URL)/makerules/main/collection.mk' > makerules/collection.mk

commit-collection::
	git add collection/log
	git diff --quiet && git diff --staged --quiet || (git commit -m "Collection $(shell date +%F)"; git push origin $(BRANCH))

load-resources::
	aws s3 sync s3://$(COLLECTION_DATASET_BUCKET_NAME)/$(REPOSITORY)/$(RESOURCE_DIR) $(RESOURCE_DIR) --no-progress

save-resources::
	aws s3 sync $(RESOURCE_DIR) s3://$(COLLECTION_DATASET_BUCKET_NAME)/$(REPOSITORY)/$(RESOURCE_DIR) --no-progress

save-logs::
	aws s3 sync $(COLLECTION_DIR)log s3://$(COLLECTION_DATASET_BUCKET_NAME)/$(REPOSITORY)/$(COLLECTION_DIR)log --no-progress

save-collection::
	aws s3 cp $(COLLECTION_DIR)log.csv s3://$(COLLECTION_DATASET_BUCKET_NAME)/$(REPOSITORY)/$(COLLECTION_DIR) --no-progress
	aws s3 cp $(COLLECTION_DIR)resource.csv s3://$(COLLECTION_DATASET_BUCKET_NAME)/$(REPOSITORY)/$(COLLECTION_DIR) --no-progress
	aws s3 cp $(COLLECTION_DIR)source.csv s3://$(COLLECTION_DATASET_BUCKET_NAME)/$(REPOSITORY)/$(COLLECTION_DIR) --no-progress
	aws s3 cp $(COLLECTION_DIR)endpoint.csv s3://$(COLLECTION_DATASET_BUCKET_NAME)/$(REPOSITORY)/$(COLLECTION_DIR) --no-progress
ifneq ($(wildcard $(COLLECTION_DIR)old-resource.csv),)
	aws s3 cp $(COLLECTION_DIR)old-resource.csv s3://$(COLLECTION_DATASET_BUCKET_NAME)/$(REPOSITORY)/$(COLLECTION_DIR) --no-progress
endif

collection/resource/%:
	@mkdir -p collection/resource/
	curl -qfsL '$(DATASTORE_URL)$(REPOSITORY)/$(RESOURCE_DIR)$(notdir $@)' > $@

collection/%.csv:
	@mkdir -p $(COLLECTION_DIR)
	curl -qfsL '$(COLLECTION_CONFIG_URL)$(notdir $@)' > $@

config:: $(COLLECTION_CONFIG_FILES)

clean::
	rm -f $(COLLECTION_CONFIG_FILES)
