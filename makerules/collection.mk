.PHONY: \
	collection\
	collect\
	clobber-today

ifeq ($(COLLECTION_DIR),)
COLLECTION_DIR=collection/
endif

# data sources
SOURCE_CSV=$(COLLECTION_DIR)source.csv
ENDPOINT_CSV=$(COLLECTION_DIR)endpoint.csv

# collection log
LOG_DIR=$(COLLECTION_DIR)log/
LOG_FILES_TODAY:=$(LOG_DIR)$(shell date +%Y-%m-%d)/

first-pass:: collect

collect:	$(SOURCE_CSV) $(ENDPOINT_CSV)
	digital-land collect $(ENDPOINT_CSV)

clobber-today::
	rm -rf $(LOG_FILES_TODAY)

# update makerules from source
update::
	curl -qsL '$(SOURCE_URL)/makerules/master/collection.mk' > makerules/collection.mk
