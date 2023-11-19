#!/usr/bin/env python3

# complete the registers in /data using the organisation-dataset

import re
import csv
from digital_land.specification import Specification

organisations = {}
specification = Specification()


def load(path):
    for row in csv.DictReader(open(path)):
        curie = row.get("organisation", "")
        if not curie:
            curie = f'{row["prefix"]}:{row["reference"]}'
        curie = curie.replace("local-authority-eng", "local-authority")

        # duplicated entries
        if curie.startswith("local-authority:Q"):
            continue

        organisations.setdefault(curie, {})
        for field, value in row.items():
            if value:
                organisations[curie][field] = value



def save(dataset):
    fieldnames = specification.schema_field[dataset]
    w = csv.DictWriter(
        open(f"data/{dataset}.csv", "w"), fieldnames=fieldnames, extrasaction="ignore"
    )
    w.writeheader()
    for organisation, row in sorted(organisations.items()):
        if row["dataset"] == dataset:
            w.writerow(row)


def fixup():
    # default dataset field from prefix field or curie
    for organisation, row in organisations.items():
        if not row.get("dataset", ""):
            prefix = row.get("prefix", "")
            if not prefix:
                prefix = row["organisation"].split(":")[0]
                prefix = prefix.replace("local-authority-eng", "local-authority")
                row["prefix"] = prefix
            row["dataset"] = prefix

        # we seem to be migrating opendatacommunities to opendatacommunities-uri
        # this may impact the brownfield-land pipeline ..
        row["opendatacommunities-uri"] = row.get(
            "opendatacommunities-uri", ""
        ) or row.get("opendatacommunities", "")

        # statistical-geography into specific field
        if row["dataset"] == "national-park-authority":
            row["national-park"] = row.get(
                "national-park", row.get("statistical-geography", "")
            )

        # Wikipedia page from URL
        row["wikipedia"] = re.sub("^http.*/", "", row.get("wikipedia", ""))


if __name__ == "__main__":
    load("tmp/local-authority.csv")
    load("var/cache/organisation.csv")
    load("dataset/organisation.csv")

    fixup()

    save("development-corporation")
    save("local-authority")
    save("national-park-authority")
    save("government-organisation")
    save("local-enterprise-partnership")
    save("nonprofit")
    save("passenger-transport-executive")
    save("public-authority")
    save("regional-park-authority")
    save("waste-authority")
