GOVERNMENT_ORGANISATION_DATASET=$(DATASET_DIR)government-organisation.csv
GOVERNMENT_ORGANISATION_TRANSFORMED_FILES=\
    $(TRANSFORMED_DIR)government-organisation/cf49bc748be86776f0879995dab3a501c2a8af729782f4a58109d2097bdf0c2c.csv

$(TRANSFORMED_DIR)government-organisation/cf49bc748be86776f0879995dab3a501c2a8af729782f4a58109d2097bdf0c2c.csv: collection/resource/cf49bc748be86776f0879995dab3a501c2a8af729782f4a58109d2097bdf0c2c
	$(run-pipeline)

$(GOVERNMENT_ORGANISATION_DATASET): $(GOVERNMENT_ORGANISATION_TRANSFORMED_FILES)
	$(build-dataset)

transformed:: $(GOVERNMENT_ORGANISATION_TRANSFORMED_FILES)

dataset:: $(GOVERNMENT_ORGANISATION_DATASET)


INTERNAL_DRAINAGE_BOARD_DATASET=$(DATASET_DIR)internal-drainage-board.csv
INTERNAL_DRAINAGE_BOARD_TRANSFORMED_FILES=\
    $(TRANSFORMED_DIR)internal-drainage-board/af14ba711cb80895ee847e45189536e93685e7b0875aa9448c783072ce0e25d7.csv

$(TRANSFORMED_DIR)internal-drainage-board/af14ba711cb80895ee847e45189536e93685e7b0875aa9448c783072ce0e25d7.csv: collection/resource/af14ba711cb80895ee847e45189536e93685e7b0875aa9448c783072ce0e25d7
	$(run-pipeline)

$(INTERNAL_DRAINAGE_BOARD_DATASET): $(INTERNAL_DRAINAGE_BOARD_TRANSFORMED_FILES)
	$(build-dataset)

transformed:: $(INTERNAL_DRAINAGE_BOARD_TRANSFORMED_FILES)

dataset:: $(INTERNAL_DRAINAGE_BOARD_DATASET)


LOCAL_AUTHORITY_ENG_DATASET=$(DATASET_DIR)local-authority-eng.csv
LOCAL_AUTHORITY_ENG_TRANSFORMED_FILES=\
    $(TRANSFORMED_DIR)local-authority-eng/a878c850cb37f513c60560fcb3865952e936f7d8429330e6674652b2fcfb1566.csv

$(TRANSFORMED_DIR)local-authority-eng/a878c850cb37f513c60560fcb3865952e936f7d8429330e6674652b2fcfb1566.csv: collection/resource/a878c850cb37f513c60560fcb3865952e936f7d8429330e6674652b2fcfb1566
	$(run-pipeline)

$(LOCAL_AUTHORITY_ENG_DATASET): $(LOCAL_AUTHORITY_ENG_TRANSFORMED_FILES)
	$(build-dataset)

transformed:: $(LOCAL_AUTHORITY_ENG_TRANSFORMED_FILES)

dataset:: $(LOCAL_AUTHORITY_ENG_DATASET)


WIKIDATA_ORGANISATION_DATASET=$(DATASET_DIR)wikidata-organisation.csv
WIKIDATA_ORGANISATION_TRANSFORMED_FILES=\
    $(TRANSFORMED_DIR)wikidata-organisation/06b648fc85727e52655a952b4d780bb20b09d773b93f47bd513eac5501f4e6ac.csv\
    $(TRANSFORMED_DIR)wikidata-organisation/25e12bcfe0a8f823fd5d7fb3fd32013db488811273e5c5716b77d81bd4c0e6a9.csv\
    $(TRANSFORMED_DIR)wikidata-organisation/4604ddc11402fee7ce8449bf4251ba8d93b45c663bd395d6878f9ffbc0a17246.csv\
    $(TRANSFORMED_DIR)wikidata-organisation/48fbba8b559a76aa52ab8f122015b18c45429f533b49efbb7a4dd39a4b2a924f.csv\
    $(TRANSFORMED_DIR)wikidata-organisation/bbf98662584c13ce5935e2b8cde7d9a3e9eebc64d75d85a31f2cbfd9ba74b80f.csv\
    $(TRANSFORMED_DIR)wikidata-organisation/bc8adea1d01be97e2c3113f307d950514d0c02d1ea1c460dba6d65465b0cd36f.csv\
    $(TRANSFORMED_DIR)wikidata-organisation/d30df0988413409a55f2f3e6f58934cb51e93abea725c0fbdee7f1fddddd039c.csv\
    $(TRANSFORMED_DIR)wikidata-organisation/d6551bd55c6186f13d31fbbab0d0c6b46c174edc4a2b6943b7afa3dd48a95af3.csv

$(TRANSFORMED_DIR)wikidata-organisation/06b648fc85727e52655a952b4d780bb20b09d773b93f47bd513eac5501f4e6ac.csv: collection/resource/06b648fc85727e52655a952b4d780bb20b09d773b93f47bd513eac5501f4e6ac
	$(run-pipeline)

$(TRANSFORMED_DIR)wikidata-organisation/25e12bcfe0a8f823fd5d7fb3fd32013db488811273e5c5716b77d81bd4c0e6a9.csv: collection/resource/25e12bcfe0a8f823fd5d7fb3fd32013db488811273e5c5716b77d81bd4c0e6a9
	$(run-pipeline)

$(TRANSFORMED_DIR)wikidata-organisation/4604ddc11402fee7ce8449bf4251ba8d93b45c663bd395d6878f9ffbc0a17246.csv: collection/resource/4604ddc11402fee7ce8449bf4251ba8d93b45c663bd395d6878f9ffbc0a17246
	$(run-pipeline)

$(TRANSFORMED_DIR)wikidata-organisation/48fbba8b559a76aa52ab8f122015b18c45429f533b49efbb7a4dd39a4b2a924f.csv: collection/resource/48fbba8b559a76aa52ab8f122015b18c45429f533b49efbb7a4dd39a4b2a924f
	$(run-pipeline)

$(TRANSFORMED_DIR)wikidata-organisation/bbf98662584c13ce5935e2b8cde7d9a3e9eebc64d75d85a31f2cbfd9ba74b80f.csv: collection/resource/bbf98662584c13ce5935e2b8cde7d9a3e9eebc64d75d85a31f2cbfd9ba74b80f
	$(run-pipeline)

$(TRANSFORMED_DIR)wikidata-organisation/bc8adea1d01be97e2c3113f307d950514d0c02d1ea1c460dba6d65465b0cd36f.csv: collection/resource/bc8adea1d01be97e2c3113f307d950514d0c02d1ea1c460dba6d65465b0cd36f
	$(run-pipeline)

$(TRANSFORMED_DIR)wikidata-organisation/d30df0988413409a55f2f3e6f58934cb51e93abea725c0fbdee7f1fddddd039c.csv: collection/resource/d30df0988413409a55f2f3e6f58934cb51e93abea725c0fbdee7f1fddddd039c
	$(run-pipeline)

$(TRANSFORMED_DIR)wikidata-organisation/d6551bd55c6186f13d31fbbab0d0c6b46c174edc4a2b6943b7afa3dd48a95af3.csv: collection/resource/d6551bd55c6186f13d31fbbab0d0c6b46c174edc4a2b6943b7afa3dd48a95af3
	$(run-pipeline)

$(WIKIDATA_ORGANISATION_DATASET): $(WIKIDATA_ORGANISATION_TRANSFORMED_FILES)
	$(build-dataset)

transformed:: $(WIKIDATA_ORGANISATION_TRANSFORMED_FILES)

dataset:: $(WIKIDATA_ORGANISATION_DATASET)
