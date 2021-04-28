# oh-sup-ct-clerk-docket-crawler

import sqlite3, pandas, urllib.request, json

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

dataDictForRequestingDocket = {
    "paramCaseNumber": '0001',
    "paramCaseYear": '1985',
    "isLoading": True,
    "action": 'GetCaseDetails',
    "caseId": '0',
    "caseNumber": None,
    "caseType": None,
    "dateFiled": None,
    "caseStatus": None,
    "caseCaption": None,
    "priorJurisdiction": None,
    "showParties": False,
    "showDocket": True,
    "showDecision": False,
    "subscriptionId": None,
    "subUserId": None,
    "noResult": False,
    "isSealed": False
}

dataDictForRequestingDocket["paramCaseNumber"] = "9999"
dataForRequestingDocket = urllib.parse.urlencode(dataDictForRequestingDocket).encode()

resp = request.urlopen(req, data=dataForRequestingDocket)
print("\n\nstatus:\n")
print(resp.status)
print("\n\nheaders:\n")
print(resp.headers)
print("\n\ncontent:\n")
resp_content = resp.read()
print(resp_content)
print("\n\ncontent json-parsed:\n")
resp_content_parsed = json.loads(resp_content)
print(resp_content_parsed)

