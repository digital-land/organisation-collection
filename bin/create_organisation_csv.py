import click
from os import listdir
from pathlib import Path
import csv

from digital_land.specification import Specification

@click.command()
@click.option("--flattened-dir", type=click.Path(exists=True), default="flattened/")
@click.option(
    "--specification-dir", type=click.Path(exists=True), default="specification/"
)
@click.option("--output-path", type=click.Path(), default="dataset/organisation.csv")
def create_org_csv_cli(flattened_dir, specification_dir,output_path):
    specification = Specification(path=specification_dir)

    # get field names
    org_field_names = specification.schema_field['organisation']

    
    # get get file list
    filenames = listdir(flattened_dir)
    filenames = [ filename for filename in filenames if filename.endswith('.csv') ]
    
    orgs = []
    for file in filenames:
        filepath = Path(flattened_dir)/ file
        with open(filepath, newline="") as f:
            for row in csv.DictReader(f):
                # hack to replace "_" with "-" in fieldnames
                if row['typology'] == 'organisation':
                    row = { k.replace("_", "-"): v for k, v in row.items() }
                    if not row.get('organisation',None):
                        row['organisation'] = row['dataset'] + ':' + row['reference']
                    org = {k:v for k,v in row.items() if k  in org_field_names}
                    orgs.append(org)

    # write list of dicts
    output_path = Path(output_path)
    with open(output_path, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=org_field_names, extrasaction='ignore')
        w.writeheader()
        w.writerows(orgs)

    # old_org_field_list = 'organisation,entity,wikidata,name,website,twitter,statistical-geography,boundary,toid,opendatacommunities,opendatacommunities-area,billing-authority,census-area,local-authority-type,government-organisation,combined-authority,esd-inventories,local-resilience-forum,region,addressbase-custodian,company,wikipedia,start-date,end-date'
    # old_org_field_list = old_org_field_list.split(',')
    # for old_field in old_org_field_list:
    #     if old_field not in org_field_names:
    #         print(old_field)

    # quick comparison to old organisationcsv
    # old_orgs = []
    # for row in csv.DictReader(open(filepath, newline="")):  
            # hack to replace "_" with "-" in fieldnames
        # row = { k.replace("_", "-"): v for k, v in row.items() }
        # if not row.get('organisation',None):
        #     row['organisation'] = row['dataset'] + ':' + row['reference']
        # old_org = {k:v for k,v in row.items() if k  in org_field_names}
        # old_orgs.append(old_org)
    
    # print(orgs)

    return


if __name__ == "__main__":
    create_org_csv_cli()
