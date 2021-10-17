.PHONY: \
	virtualenv\
	workon\
	dev

# useful when developing
# export PIP_REQUIRE_VIRTUALENV=true

# create a virtual environment
virtualenv::
	python3 -m venv .venv/$$(basename $$PWD)

workon::
	bash --init-file .venv/$$(basename $$PWD)/bin/activate

# create a symbolic link from the virtual environment to a cloned repository
dev::
ifndef VIRTUAL_ENV
	$(error not in a virtual environment)
endif
	pip install -e ../digital-land-python/

prune::
	rm -rf ./.venv

makerules::
	curl -qfsL '$(SOURCE_URL)/makerules/main/development.mk' > makerules/development.mk
