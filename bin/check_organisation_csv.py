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
bas = {}
odcs = {}
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
        print(f'{line["severity"]} {line["prefix"]}:{line["reference"]} {issue} {field} {value}', file=sys.stderr)
    issues.append(line)


def save_issues(path):
    fieldnames = ["datapackage", "severity", "entity", "prefix", "reference", "issue", "field", "value"]
    w = csv.DictWriter(open(path, "w"), fieldnames=fieldnames, extrasaction="ignore")
    w.writeheader()
    for row in issues:
        w.writerow(row)


def check():
    for organisation, row in organisations.items():

        # look for duplicate entities
        if row["entity"] in entities:
            log_issue("error", row, "duplicate entity")
        else:
            entities[row["entity"]] = organisation

        # check wikidata
        wikidata = row.get("wikidata", "")
        if wikidata and wikidata in wikidatas:
            severity = "warning" if row["entity"] in ["600001"] else "error"
            log_issue(severity, row, "duplicate value", field="wikidata", value=row["wikidata"])
        else:
            wikidatas[row["wikidata"]] = organisation

        # check LPA value against dataset
        lpa = row.get("local-planning-authority", "")
        if not lpa:
            if (row["dataset"] in ["local-authority", "national-park-authority"]) and (
                row.get("local-authority-type", "") not in ["CTY", "COMB", "SRA"]
            ):
                severity = "warning" if row.get("end-date", "") else "error"
                log_issue(severity, row, "missing", field="local-planning-authority")
        elif lpa not in lpas:
            log_issue("error", row, "unknown", field="local-planning-authority", value=lpa)
        else:
            lpas[lpa]["organisation"] = organisation

        # check billing-authority
        ba = row.get("billing-authority", "")
        if not ba:
            if row["dataset"] not in ["government-organisation"]:
                severity = "warning" if row.get("end-date", "") else "error"
                log_issue(severity, row, "missing", field="billing-authority")
        elif ba in bas:
            log_issue("error", row, "duplicate value", field="billing-authority", value=row["billing-authority"])
        else:
            bas[row["billing-authority"]] = organisation

        # check opendatacommunities-uri
        odc = row.get("opendatacommunities-uri", "")
        if not odc:
            if row["dataset"] not in ["government-organisation"]:
                severity = "warning" if row.get("end-date", "") else "error"
                log_issue(severity, row, "missing", field="opendatacommunities-uri")
        elif odc in odcs:
            log_issue("error", row, "duplicate value", field="opendatacommunities-uri", value=row["opendatacommunities-uri"])
        else:
            odcs[row["opendatacommunities-uri"]] = organisation



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
