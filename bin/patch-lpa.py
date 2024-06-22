#!/usr/bin/env python3

import csv
import pandas as pd


# list of LPAs from our role_provision table
lpas = pd.read_csv('https://datasette.planning.data.gov.uk/digital-land/role_organisation.csv?role=local-planning-authority&_labels=on&_size=max')

w = None
r = csv.DictReader(open("data/local-authority.csv"))

for row in r:
    if not w:
        w = csv.DictWriter(open("local-authority.csv", "w", newline=""), fieldnames=r.fieldnames)
        w.writeheader()

    if len(lpas.loc[lpas["organisation"] == row["organisation"]]):
        if not row["local-planning-authority"]:
            print(f'{row["organisation"]} missing local-planning-authority value', end="")
            if row["end-date"]:
                print(" *ignored*")
            else:
                print(" *NEED ATTENTION*")
    else:
        if row["local-planning-authority"]:
            print(f'{row["organisation"]} has {row["local-planning-authority"]} but is not an LPA', end="")
            if row["local-authority-type"] not in ["CTY", "COMB"]:
                print(" *kept*")
            else:
                print(" *removed*")
                row["local-planning-authority"] = ""

    w.writerow(row)

