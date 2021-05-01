# clerk docket crawler

import sys, datetime, urllib.request, json
import sqlite3
import pandas as pd

# use command line parameters to determine the  year and case number with which this execution instance should begin and end

first_year_to_process = int(sys.argv[1])
print("first year to process = " + str(first_year_to_process))

first_case_number_to_process = int(sys.argv[2])
print("first case number to process = " + str(first_case_number_to_process))

last_year_to_process = int(sys.argv[3])
print("last year to process = " + str(last_year_to_process))

# connect to the database
conn = sqlite3.connect("./data/oh_sp_ct_data.sqlite")

# set up the very basic info for the HTTPS requests we will make below
base_docket_url = "https://www.supremecourt.ohio.gov/Clerk/ecms/Ajax.ashx"
req = urllib.request.Request(base_docket_url, method="POST")

# the following headers are based on what can be seen when these kinds of requests are done through the Chrome browser 
req.add_header('accept', '*/*')
req.add_header('accept-encoding', 'gzip, deflate, br')
req.add_header('accept-language', 'en-US,en;q=0.9')
req.add_header('connection', 'keep-alive')
req.add_header('content-type', 'application/x-www-form-urlencoded; charset=UTF-8')
req.add_header('origin', 'https://www.supremecourt.ohio.gov')
req.add_header('referer', 'https://www.supremecourt.ohio.gov/Clerk/ecms/?')
req.add_header('sec-fetch-dest', 'empty')
req.add_header('sec-fetch-mode', 'cors')
req.add_header('sec-fetch-site', 'same-origin')
req.add_header('x-csrf-token', 'hP3ZyrdvKmaPk4kVjgko7xxNUob') # value from https://www.supremecourt.ohio.gov/Clerk/ecms/scripts/dist/site.min.js
req.add_header('x-requested-with', 'XMLHttpRequest')
req.add_header('user-agent','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.141 Safari/537.36')


# Get the last case number for each year from the first year through the last year...

data_dict_for_requesting_final_cases_for_year = {
"caseParams": "true",
"isSearching": "true",
"paramCaseFiledFrom": "12-21-",
"paramCaseFiledTo": "12-31-",
"action": "CaseSearch",
"paramPartyFirstName": "",
"paramPartyLastName": "",
"paramPartyEntity": "",
"paramAttyFirstName": "",
"paramAttyLastName": ""
}


# the following dictionary data was retrieved after setting the first_year_to_process variable to 1985.
# because the numbers for past years shouldn't change, we don't really need to do anything more than get the years subsequent to those in this dictionary 
last_case_number_by_year = {
    1985: 2029, 1986: 2101, 1987: 2217, 1988: 2215, 1989: 2224, 1990: 2557, 1991: 2576, 1992: 2647, 1993: 2639, 1994: 2770, 
    1995: 2679, 1996: 2889, 1997: 2731, 1998: 2728, 1999: 2327, 2000: 2355, 2001: 2284, 2002: 2249, 2003: 2237, 2004: 2178, 
    2005: 2444, 2006: 2407, 2007: 2459, 2008: 2506, 2009: 2363, 2010: 2293, 2011: 2207, 2012: 2188, 2013: 2055, 2014: 2257, 
    2015: 2113, 2016: 1914, 2017: 1828, 2018: 1859, 2019: 1819, 2020: 1593
}

current_year = datetime.date.today().year

for year in range(first_year_to_process, last_year_to_process+1):
    print("Retrieving final CaseNumber for year " + str(year))

    month_day_from = "12-21"
    month_day_to = "12-31"
    if year == current_year:
        month_day_from = str(datetime.date.today().month).zfill(2) + "-01"
        month_day_to = str(datetime.date.today().month).zfill(2) + "-" + str(datetime.date.today().day).zfill(2)

    data_dict_for_requesting_final_cases_for_year["paramCaseFiledFrom"] = month_day_from + "-" + str(year)
    data_dict_for_requesting_final_cases_for_year["paramCaseFiledTo"] = month_day_to + "-" + str(year)

    data_for_request = urllib.parse.urlencode(data_dict_for_requesting_final_cases_for_year).encode()

    resp = urllib.request.urlopen(req, data=data_for_request)
    print("Status:" + str(resp.status))
    resp_content = resp.read()
    resp_content_parsed = json.loads(resp_content)
    #print(resp_content_parsed)
    print( "Retrieved " + str(len(resp_content_parsed)) + " cases. Sorting..." )
    resp_content_parsed = sorted(resp_content_parsed, key=lambda d: d['CaseNumber'], reverse=True)
    last_case_number = resp_content_parsed[0]["CaseNumber"]
    print(last_case_number)

    last_case_number_by_year[year] = int(last_case_number[-4:])

print(last_case_number_by_year)

data_dict_for_requesting_docket = {
    "paramCaseNumber": '0001',
    "paramCaseYear": '1985',
    "isLoading": "true",
    "action": 'GetCaseDetails',
    "caseId": '0',
    "caseNumber": "",
    "caseType": "",
    "dateFiled": "",
    "caseStatus": "",
    "caseCaption": "",
    "priorJurisdiction": "",
    "showParties": "false",
    "showDocket": "true",
    "showDecision": "false",
    "subscriptionId": "",
    "subUserId": "",
    "noResult": "false",
    "isSealed": "false"
}

for year in range(first_year_to_process, last_year_to_process+1):
    print("Retrieving cases for year " + str(year))
    last_case_number = last_case_number_by_year[year]

    if year != first_year_to_process:
        first_case_number_to_process = 1

    for case_number in range(first_case_number_to_process, last_case_number+1):
        case_number_id = str(year) + "-" + str(case_number).zfill(4)
        print("To restart: python docket-crawler.py " + str(year) + " " + str(case_number) + " " + str(last_year_to_process))

        data_dict_for_requesting_docket["paramCaseNumber"] = str(case_number).zfill(4)
        data_dict_for_requesting_docket["paramCaseYear"] = str(year)

        data_for_request = urllib.parse.urlencode(data_dict_for_requesting_docket).encode()

        resp = urllib.request.urlopen(req, data=data_for_request)

        if resp.status != 200:
            print("ERROR upon trying to retrieve with data_for_request = " + data_for_request)
            print("STATUS:" + str(resp.status))
            print("HEADERS:")
            print(resp.headers + "\n")
            print("CONTENT/BODY:")
            print(resp.read())
            sys.exit(1)

        resp_content = resp.read()
        #resp_content_parsed = json.loads(resp_content)
        #print(resp_content_parsed)

        # id, last_retrieved, raw_data
        df = pd.DataFrame([{
            "id":case_number_id,
            "last_retrieved":str( datetime.datetime.now().isoformat()),
            "raw_data":resp_content.decode()
        }])

        #note:  the sqlite3 table has a ON CONFLICT clause that forces an update when this code attempts to insert an id that is already in the table
        #
        # CREATE TABLE clerk_docket_data (
        # 	id TEXT,
        # 	last_retrieved TEXT,
        # 	raw_data TEXT,
        # 	CONSTRAINT clerk_docket_data_PK PRIMARY KEY (id) ON CONFLICT REPLACE
        # );
        #
        # An alternative to that would be the following:  https://docs.sqlalchemy.org/en/14/dialects/sqlite.html#insert-on-conflict-upsert

        df.to_sql("clerk_docket_data", conn, if_exists='append', index=False)

conn.close()

