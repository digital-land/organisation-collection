#!/usr/bin/env python3

import csv

lookups = {
    "north-east": "E12000001",
    "north-west": "E12000002",
    "yorkshire-and-the-humber": "E12000003",
    "east-midlands": "E12000004",
    "west-midlands": "E12000005",
    "east-of-england": "E12000006",
    "london": "E12000007",
    "south-east": "E12000008",
    "south-west": "E12000009",

    "E47000008": "E12000006",
    "E06000028": "E12000009",
    "E07000048": "E12000009",
    "E07000049": "E12000009",
    "E06000029": "E12000009",
    "E07000053": "E12000009",
    "E07000048": "E12000009",
    "E07000052": "E12000009",
    "E07000050": "E12000009",
    "E07000191": "E12000009",
    "E07000051": "E12000009",
    "E07000204": "E12000006",
    "E07000190": "E12000009",
    "E12000007": "E12000007",
    "E47000001": "E12000002",
    "E47000010": "E12000001",
    "E47000011": "E12000001",
    "E47000006": "E12000001",
    "E47000007": "E12000005",
    "E47000002": "E12000003",
    "E47000009": "E12000005",
    "E07000205": "E12000006",
    "E07000201": "E12000006",
    "E07000206": "E12000006",
    "E47000003": "E12000003",
}

for row in csv.DictReader(open("tmp/lad-region.csv")):
    lookups[row["LAD23CD"]] = row["RGN23CD"]


w = None
r = csv.DictReader(open("data/local-authority.csv"))

for row in r:
    if not w:
        w = csv.DictWriter(open("local-authority.csv", "w", newline=""), fieldnames=r.fieldnames)
        w.writeheader()

    if row["local-authority-district"] in lookups:
        row["region"] = lookups[row["local-authority-district"]]

    if row["region"] in lookups:
        row["region"] = lookups[row["region"]]

    w.writerow(row)

