#!/usr/bin/env python3

import csv

curies = {}


def add_curie(prefix, reference, entity):
    curies[prefix + ":" + reference] = {
        "prefix": prefix,
        "reference": reference,
        "entity": entity,
    }


for row in csv.DictReader(open("var/cache/organisation.csv")):
    entity = row["entity"]
    prefix, reference = row["organisation"].split(":")
    add_curie(prefix, reference, entity)

    if prefix == "local-authority-eng":
        add_curie("local-authority", reference, entity)
        add_curie("local-authority", row["statistical-geography"], entity)

    for prefix in ["wikidata", "billing-authority", "esd-inventories", "addressbase-custodian", "company"]:
        reference = row.get(prefix, "")
        if reference:
            add_curie(prefix, reference, entity)



w = csv.DictWriter(
    open("pipeline/lookup.csv", "w", newline=""),
    fieldnames=[
        "prefix",
        "reference",
        "entity",
    ],
    extrasaction="ignore",
)
w.writeheader()
for curie, row in sorted(curies.items(), key=lambda item: int(item[1]["entity"])):
    w.writerow(row)
