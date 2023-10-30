include makerules/makerules.mk
include makerules/development.mk
include makerules/collection.mk
include makerules/pipeline.mk

# build the organisation.csv file from organisation datasets
# this could be derived from the specification ..
# this makes sure all of the other files are made first (inc. the flattened files)
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

# may need to make this specific at a later date
dataset/organisation.csv: $(ORGANISATION_DATASETS)
	python3 bin/create_organisation_csv.py --output-path $@ 

dataset:: dataset/organisation.csv
