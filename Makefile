include makerules/makerules.mk
include makerules/development.mk
include makerules/collection.mk
include makerules/pipeline.mk

package:: dataset/organisation.csv dataset/organisation-check.csv

dataset/organisation.csv:
	digital-land organisation-create --download-url="https://files.planning.data.gov.uk/organisation-collection/dataset" --output-path $@

# check organisation datapackage
dataset/organisation-check.csv: dataset/organisation.csv var/cache/local-planning-authority.csv
	digital-land organisation-check --output-path $@

var/cache/local-planning-authority.csv:
	@mkdir -p $(CACHE_DIR)
	curl -qfs "https://files.planning.data.gov.uk/dataset/local-planning-authority.csv" > $(CACHE_DIR)local-planning-authority.csv
