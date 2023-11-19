#!/usr/bin/env python3

# check the integrity of the organisation.csv file

import sys
import click
import re
import csv
from digital_land.specification import Specification


organisations = {}
specification = Specification()
lpas = {}
entities = {}
wikidatas = {}
curies = {}
issues = []


def load_lpas(path):
    for row in csv.DictReader(open(path)):
        lpas[row["reference"]] = row


def load(path):
    for row in csv.DictReader(open(path)):
        curie = row.get("organisation", "")
        if not curie:
            curie = f'{row["prefix"]}:{row["reference"]}'
        organisations.setdefault(curie, {})
        for field, value in row.items():
            if value:
                organisations[curie][field] = value


def log_issue(severity, row, issue, field="", value=""):
    line = {
        "datapackage": "organisation",
        "entity": row["entity"],
        "prefix": row["prefix"],
        "reference": row["reference"],
        "severity": severity,
        "issue": issue,
        "field": field,
        "value": value,
    }
    if severity in ["critical", "error"]:
        print(line, file=sys.stderr)
    issues.append(line)


def save_issues(path):
    fieldnames = ["datapackage", "entity", "prefix", "reference", "issue", "field", "value"]
    w = csv.DictWriter(open(path, "w"), fieldnames=fieldnames, extrasaction="ignore")
    w.writeheader()
    for row in issues:
        w.writerow(row)


def check():
    for organisation, row in organisations.items():
        if row["entity"] in entities:
            log_issue("error", row, "duplicate entity")
        else:
            entities[row["entity"]] = organisation

        wikidata = row.get("wikidata", "")
        if wikidata and wikidata in wikidatas:
            log_issue("warning", row, "duplicate value", field="wikidata", value=row["wikidata"])
        else:
            wikidatas[row["wikidata"]] = organisation

        # tick LPA value
        lpa = row.get("local-planning-authority", "")
        if not lpa:
            if (row["dataset"] in ["local-authority", "national-park-authority"]) and (
                row.get("local-authority-type", "") not in ["CTY", "COMB"]
            ):
                log_issue("warning", row, "missing", field="local-planning-authority")
        elif lpa not in lpas:
            log_issue("error", row, "unknown", field="local-planning-authority", value=lpa)
        else:
            lpas[lpa]["organisation"] = organisation


@click.command()
@click.option(
    "--output-path", type=click.Path(), default="dataset/organisation-check.csv"
)
def cli(output_path):
    load_lpas("var/cache/local-planning-authority.csv")
    load("dataset/organisation.csv")
    check()
    save_issues(output_path)


if __name__ == "__main__":
    cli()
