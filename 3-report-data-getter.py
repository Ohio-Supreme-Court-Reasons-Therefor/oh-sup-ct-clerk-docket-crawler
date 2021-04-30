# get report data via clerk

import sys, urllib.request, io
import sqlite3
import pandas as pd
import pdfplumber

# use command line parameter to determine which year to process

year = sys.argv[1]
print("year to process = " + year)

# connect to the database

conn = sqlite3.connect("./data/oh_sp_ct_data.sqlite")

df = pd.read_sql("SELECT report_url FROM report_data_via_clerk WHERE report_url LIKE '%/"+year+"-ohio%' AND document IS NULL",conn)
df.sort_values("report_url",inplace=True)

for index in df.index:
    report_url = df.loc[index,'report_url']
    print(report_url)

    # set up the very basic info for the HTTPS requests we will make below
    req = urllib.request.Request(report_url, method="GET")

    # the following headers are based on what can be seen when these kinds of requests are done through the Chrome browser 
    req.add_header('accept', '*/*')
    req.add_header('accept-encoding', 'gzip, deflate, br')
    req.add_header('accept-language', 'en-US,en;q=0.9')
    req.add_header('connection', 'keep-alive')
    req.add_header('origin', 'https://www.supremecourt.ohio.gov')
    req.add_header('referer', 'https://www.supremecourt.ohio.gov/Clerk/ecms/?')
    req.add_header('sec-fetch-dest', 'empty')
    req.add_header('sec-fetch-mode', 'cors')
    req.add_header('sec-fetch-site', 'same-origin')
    req.add_header('x-csrf-token', 'hP3ZyrdvKmaPk4kVjgko7xxNUob') # value from https://www.supremecourt.ohio.gov/Clerk/ecms/scripts/dist/site.min.js
    req.add_header('x-requested-with', 'XMLHttpRequest')
    req.add_header('user-agent','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.141 Safari/537.36')

    resp = urllib.request.urlopen(req)

    if resp.status != 200:
        print("ERROR upon trying to retrieve data")
        print("STATUS:" + str(resp.status))
        print("HEADERS:")
        print(resp.headers + "\n")
        print("CONTENT/BODY:")
        print(resp.read())
        sys.exit(1)

    resp_content = resp.read()

    f = io.BytesIO(resp_content)

    pdf = pdfplumber.open(f)
    page_margin_to_ignore_in_points = 65
    page_text = ""
    for pdf_page in pdf.pages:
        cropped_pdf_page = pdf_page.crop(
            (page_margin_to_ignore_in_points, 
            page_margin_to_ignore_in_points, 
            pdf_page.width-page_margin_to_ignore_in_points, 
            pdf_page.height-page_margin_to_ignore_in_points)
        )
        extracted_text = cropped_pdf_page.extract_text()
        if extracted_text == None:
            extracted_text = ""
        page_text += extracted_text + "\n"

    #print(page_text)
    df2 = pd.DataFrame([{
        "report_url":report_url,
        "document": resp_content,
        "document_text": page_text
    }])

    df2.to_sql("report_data_via_clerk", conn, if_exists='append', index=False)

conn.close()
