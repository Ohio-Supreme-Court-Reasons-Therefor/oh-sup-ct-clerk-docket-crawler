# t.b.d.

import sys, datetime, urllib.request, json
from sqlalchemy import create_engine
import pandas as pd
import re


# connect to the database
conn = create_engine('sqlite:///data/oh_sp_ct_data.sqlite').connect()

df = pd.read_sql_table("data_from_clerk",conn)
df.sort_values("id",inplace=True)

re_for_report_url = re.compile("https.*?rod.*?\.pdf")

for index in df.index:
    raw_data = df.loc[index,'raw_data']
    if raw_data[0] == "{":
        print(df.loc[index,'id'])
        parsed_data = json.loads(raw_data)
        df.loc[index,'status'] = parsed_data["CaseInfo"]["Status"]
        if parsed_data["CaseInfo"]["Status"] == 'Disposed':
            for docket_item in parsed_data["DocketItems"]:
                if docket_item["FilingParties"] == "DISPOSITIVE":
                    desc = docket_item["Description"]
                    df.loc[index,'dispositive_docket_item_description'] = desc
                    mo = re_for_report_url.search(desc)
                    if mo != None:
                        df.loc[index,'dispositive_docket_item_report_url'] = mo.group(0)

df.to_sql("data_from_clerk", conn, if_exists='append', index=False)


conn.close()

# CREATE TABLE "report_data_via_clerk" (
# 	report_url TEXT,
# 	document BLOB,
# 	document_text TEXT,
# 	CONSTRAINT documents_from_clerk_PK PRIMARY KEY (report_url)
# );

# INSERT INTO report_data_via_clerk (report_url) 
# SELECT distinct dispositive_docket_item_report_url FROM data_from_clerk 
# WHERE dispositive_docket_item_report_url IS NOT NULL 
# AND dispositive_docket_item_report_url NOT IN (SELECT report_url FROM report_data_via_clerk)
