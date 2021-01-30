// oh-sup-ct-clerk-docket-crawler

// This docket crawler program uses the node-fetch library to retrieve docket data.
// The library avoids the overhead of using a browser (or even a headless browser like via puppeter).
// More info about fetch here:  https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API/Using_Fetch

const fse = require('fs-extra');
const nodeFetch = require('node-fetch');
const fetch = require('fetch-cookie')(nodeFetch);
const querystring = require('querystring');

(async () => {
    try {
        console.log('Starting at ' + new Date());

        var fetchInit = {
            'headers': {
                'accept': '*/*',
                'accept-encoding': 'gzip, deflate, br',
                'accept-language': 'en-US,en;q=0.9',
                'connection': 'keep-alive',
                'content-type': 'application/x-www-form-urlencoded; charset=UTF-8',
                'origin': 'https://www.supremecourt.ohio.gov',
                'referer': 'https://www.supremecourt.ohio.gov/Clerk/ecms/?',
                'sec-fetch-dest': 'empty',
                'sec-fetch-mode': 'cors',
                'sec-fetch-site': 'same-origin',
                'x-csrf-token': 'hP3ZyrdvKmaPk4kVjgko7xxNUob', // value from https://www.supremecourt.ohio.gov/Clerk/ecms/scripts/dist/site.min.js
                'x-requested-with': 'XMLHttpRequest',
                'user-agent':
                    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.141 Safari/537.36',
            },
            'referrerPolicy': 'strict-origin-when-cross-origin',
            'body': '',
            'method': 'POST',
            'mode': 'cors',
            'credentials': 'include',
        };

        var bodyObjForRequestingDocket = {
            paramCaseNumber: '0001',
            paramCaseYear: '1985',
            isLoading: true,
            action: 'GetCaseDetails',
            caseId: '0',
            caseNumber: null,
            caseType: null,
            dateFiled: null,
            caseStatus: null,
            caseCaption: null,
            priorJurisdiction: null,
            showParties: false,
            showDocket: true,
            showDecision: false,
            subscriptionId: null,
            subUserId: null,
            noResult: false,
            isSealed: false,
        };

        var jsonForDocketWithBadResponse = {
            'CaseInfo': {
                'CaseNumber': '',
                'BadResponseText': ''
            },
        };

        var params = fse.readJSONSync('tmp/params.json');

        console.log('Starting with ' + params.caseYear.toString() + '-' + params.caseNumber.toString().padStart(4, '0') + '\n');

        // Iterate through cases
        do {
            fse.writeJSONSync('tmp/params.json', params);

            bodyObjForRequestingDocket.paramCaseYear = params.caseYear.toString();
            bodyObjForRequestingDocket.paramCaseNumber = params.caseNumber.toString().padStart(4, '0');

            var caseYearDashCaseNum = bodyObjForRequestingDocket.paramCaseYear + '-' + bodyObjForRequestingDocket.paramCaseNumber;

            process.stdout.clearLine();
            process.stdout.cursorTo(0);
            process.stdout.write('Requesting ' + caseYearDashCaseNum);

            fetchInit.body = querystring.stringify(bodyObjForRequestingDocket);

            var respText;
            try {
                var response = await fetch('https://www.supremecourt.ohio.gov/Clerk/ecms/Ajax.ashx', fetchInit);
                respText = await response.text();
            }
            catch(e) {
                respText = e.toString();
            }

            process.stdout.clearLine();
            process.stdout.cursorTo(0);
            process.stdout.write('Processing response for '+caseYearDashCaseNum+'.  Body\'s first 120 chars = [' + respText.substr(0, 120) + '] ');

            var respTextInvalidJson = false;
            try {
                JSON.parse(respText);
            } catch (e) {
                respTextInvalidJson = true;
            }

            // If we received a bad response...
            if (
                respText === '"Too many results"' ||
                respText === '' ||
                respText === null ||
                respText === undefined ||
                respText.substr(0, 48) !== '{"UserID":0,"SubscriptionID":0,"CaseInfo":{"ID":' ||
                respTextInvalidJson
            ) {
                jsonForDocketWithBadResponse.CaseInfo.CaseNumber =
                    bodyObjForRequestingDocket.paramCaseYear + '-' + bodyObjForRequestingDocket.paramCaseNumber;
                jsonForDocketWithBadResponse.CaseInfo.BadResponseText = respText;
                params.sequentialBadResponses.push(','+JSON.stringify(jsonForDocketWithBadResponse)+'\n');
                if (params.sequentialBadResponses.length == 50) {
                    params.sequentialBadResponses = [];
                    params.caseYear++;
                    if (params.caseYear > new Date().getFullYear()) {
                        break;
                    }
                    params.caseNumber = 0;
                }
            } else {
                var dataFileName = 'tmp/data' + params.caseYear + '.txt'; 
                if (params.sequentialBadResponses.length > 0) {
                    fse.appendFileSync(dataFileName,params.sequentialBadResponses.join());
                    params.sequentialBadResponses = [];
                }
                fse.appendFileSync(dataFileName, ',' + respText + '\n');
            }

            params.caseNumber++;

        } while (true);

    } catch (error) {
        console.error('\nERROR!', error);
    }
    console.log('\nDONE!');
})();
