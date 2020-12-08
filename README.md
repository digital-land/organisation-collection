# Organisation collection

[![License](https://img.shields.io/github/license/mashape/apistatus.svg)](https://github.com/digital-land/brownfield-land/blob/master/LICENSE)

A collection of organisations collected from GOV.UK registers and other places, including:

* [Government Organisation Register](https://government-organisation.register.gov.uk/)
* [Local Authority England Register](https://local-authority-eng.register.gov.uk/)
* [Internal Drainage Board Register](https://internal-drainage-board.register.gov.uk/)

and the following locally managed lists:

* [local/development-corporation.csv](local/development-corporationt.csv) — development corporations
* [local/regional-park-authority.csv](local/regional-park-authority.csv) — regional park authorities
* [local/national-park-authority.csv](local/national-park-authority.csv) — national park authorities
* [local/transport-authority.csv](local/transport-authority.csv) — transport authorities
* [local/waste-disposal-authority.csv](local/waste-disposal-authority.csv) — waste disposal authorities
* [local/public-authority.csv](local/public-authority.csv) — miscellaneous public authorities

The national dataset is a in a format consistent with other Digital Land datasets as defined by the [organisation schema](https://digital-land.github.io/specification/schema/organisation/).

# Collection

* [collection/source.csv](collection/source.csv) — the list of data sources by organisation, see [specification/source](https://digital-land.github.io/specification/schema/source/)
* [collection/endpoint.csv](collection/endpoint.csv) — the list of endpoint URLs for the collection, see [specification/endpoint](https://digital-land.github.io/specification/schema/endpoint)
* [collection/resource/](collection/resource/) — collected resources
* [collection/log/](collection/log/) — individual log JSON files, created by the collection process
* [collection/log.csv](collection/log.csv) — a collection log assembled from the individual log files, see [specification/log](https://digital-land.github.io/specification/schema/log)
* [collection/resource.csv](collection/resource.csv) — a list of collected resources, see [specification/resource](https://digital-land.github.io/specification/schema/resource)

# Updating the collection

We recommend working in [virtual environment](http://docs.python-guide.org/en/latest/dev/virtualenvs/) before installing the python [requirements](requirements.txt), [makerules](https://github.com/digital-land/makerules) and other dependencies:

    $ make update
    $ make init
    $ make

# Nightly collection

The collection is [updated nightly](https://github.com/digital-land/brownfield-land-collection-new/actions) by the [GitHub Action](.github/workflows/run.yml).

# Licence

The software in this project is open source and covered by the [LICENSE](LICENSE) file.

Individual datasets copied into this repository may have specific copyright and licensing, otherwise all content and data in this repository is
[© Crown copyright](http://www.nationalarchives.gov.uk/information-management/re-using-public-sector-information/copyright-and-re-use/crown-copyright/)
and available under the terms of the [Open Government 3.0](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/) licence.
