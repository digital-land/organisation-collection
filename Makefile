include makerules/makerules.mk
include makerules/development.mk
include makerules/collection.mk
include makerules/pipeline.mk

# 
#  Combine the individual organisation datasets into a single organisation.csv  
#  TBD: make from a specification datapackage definition
#
ORGANISATION_DATASETS=\
	$(DEVELOPMENT_CORPORATION_DATASET)\
	$(GOVERNMENT_ORGANISATION_DATASET)\
	$(LOCAL_AUTHORITY_DATASET)\
	$(NATIONAL_PARK_AUTHORITY_DATASET)\
	$(NONPROFIT_DATASET)\
	$(PASSENGER_TRANSPORT_EXECUTIVE_DATASET)\
	$(PUBLIC_AUTHORITY_DATASET)\
	$(REGIONAL_PARK_AUTHORITY_DATASET)\
	$(WASTE_AUTHORITY_DATASET)

dataset:: dataset/organisation.csv dataset/organisation-check.csv

dataset/organisation.csv: $(ORGANISATION_DATASETS)
	python3 bin/create_organisation_csv.py --output-path $@ 

# check organisation datapackage
dataset/organisation-check.csv: dataset/organisation.csv var/cache/local-planning-authority.csv
	python3 bin/check_organisation_csv.py --output-path $@ 

var/cache/local-planning-authority.csv:
	@mkdir -p $(CACHE_DIR)
	curl -qfs "https://files.planning.data.gov.uk/dataset/local-planning-authority.csv" > $(CACHE_DIR)local-planning-authority.csv
