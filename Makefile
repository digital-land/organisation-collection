include makerules/makerules.mk
include makerules/development.mk
include makerules/collection.mk
include makerules/pipeline.mk

package:: dataset/organisation.csv dataset/organisation-check.csv

dataset/organisation.csv:
	aws s3 sync s3://$(ENVIRONMENT)-collection-data/organisation-collection/dataset $(DATASET_DIR) --no-progress
	digital-land organisation-create --dataset-dir=$(DATASET_DIR) --output-path $@

dataset/organisation-check.csv: dataset/organisation.csv var/cache/local-planning-authority.csv
	digital-land organisation-check --output-path $@

var/cache/local-planning-authority.csv:
	@mkdir -p $(CACHE_DIR)
	curl -qfs "https://files.planning.data.gov.uk/dataset/local-planning-authority.csv" > $(CACHE_DIR)local-planning-authority.csv
