#!/usr/bin/env python3

# combine organisation collection datasets into a single organisation.csv

import sys
import csv


# get fieldnames from the specification
fieldnames = set()
for row in csv.DictReader(open("specification/dataset-field.csv", newline="")):
    if row["dataset"] == "organisation":
        fieldnames.add(row["field"])

fieldnames = sorted(fieldnames)

entities = {}

output_path = sys.argv[1]

for path in sys.argv[2:]:

    # hack path to be the flattened version
    path = path.replace("/dataset/", "/flattened/")

    for row in csv.DictReader(open(path, newline="")):
        # hack to replace "_" with "-" in fieldnames
        row = { k.replace("_", "-"): v for k, v in row.items() }
        entities[row["entity"]] = row


w = csv.DictWriter(open(output_path, "w", newline=""), fieldnames=fieldnames, extrasaction='ignore')
w.writeheader()

for entity in sorted(entities, key=int):
    row = entities[entity]

    if not row.get("name", ""):
        print("error:", entity, "missing name", file=sys.stderr)

    w.writerow(row)
