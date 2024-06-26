include makerules/makerules.mk
include makerules/development.mk
include makerules/collection.mk
include makerules/pipeline.mk

package:: dataset/organisation.csv dataset/organisation-check.csv

dataset/organisation.csv:
ifeq ($(HOISTED_COLLECTION_DATASET_BUCKET_NAME),digital-land-$(ENVIRONMENT)-collection-dataset-hoisted)
	aws s3 sync $(FLATTENED_DIR) s3://$(HOISTED_COLLECTION_DATASET_BUCKET_NAME)/data/ --no-progress
else
	aws s3 sync $(FLATTENED_DIR) s3://$(HOISTED_COLLECTION_DATASET_BUCKET_NAME)/dataset/ --no-progress
endif
	digital-land organisation-create --flattened-dir=$(FLATTENED_DIR) --output-path $@

# check organisation datapackage
dataset/organisation-check.csv: dataset/organisation.csv var/cache/local-planning-authority.csv
	digital-land organisation-check --output-path $@

var/cache/local-planning-authority.csv:
	@mkdir -p $(CACHE_DIR)
	curl -qfs "https://files.planning.data.gov.uk/dataset/local-planning-authority.csv" > $(CACHE_DIR)local-planning-authority.csv
