#!/usr/bin/env python3

import csv

entities = {}

for row in csv.DictReader(open("collection/resource/b646b4d197f1513056edb3f577e6ccd908331a0621021955cc19860faa763691")):
    entities[row["wikidata"]] = row

for row in csv.DictReader(open("pipeline/lookup.csv")):
    if row["prefix"] == "wikidata" and row["reference"] in entities:
        entities[row["reference"]]["entity"] = row["entity"]

for wikidata, row in sorted(entities.items()):
    entity = row.get("entity", "")
    if not entity:
        print(wikidata, row["name"], row["start-date"], row["end-date"])
