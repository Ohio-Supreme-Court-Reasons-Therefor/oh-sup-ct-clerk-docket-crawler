const fse = require('fs-extra');
const nodeFetch = require('node-fetch');
const fetch = require('fetch-cookie')(nodeFetch);
const util = require('util');
const streamPipeline = util.promisify(require('stream').pipeline);

(async () => {
    try {
        var startDate = new Date();
        console.log('Starting at ' + new Date());

        var decisionNumber = parseInt(fse.readFileSync('8-download-decisions.json').toString().trim());
        var decisionNumberStart = decisionNumber;
        // Note:  The "decisions" that this program downloads are the decisions listed in the "dispositive_decision_items.json" file
        //        which is itself a product of the 4-export-to-csv.bat program.  (The file is the only non-csv export file.)
        var decisions = fse.readJSONSync('data/dispositive_decision_items.json');

        console.log('Starting with decision number ' + decisionNumber + '.\n');

        var fetchInit = {
            'headers': {
                'accept': '*/*',
                'accept-encoding': 'gzip, deflate',
                'accept-language': 'en-US,en;q=0.9',
                'connection': 'keep-alive',
                'user-agent':
                    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.141 Safari/537.36',
            },
            'method': 'GET',
        };

        // Iterate through cases
        for (; decisionNumber < decisions.length; decisionNumber++) {
            fse.writeFileSync('8-download-decisions.json', decisionNumber.toString());

            var endTime = '?';
            if (decisionNumber != decisionNumberStart) {
                var elapsedTime = new Date().getTime() - startDate.getTime();
                var timePerDecision = elapsedTime / (decisionNumber - decisionNumberStart);
                remainingTime = (decisions.length - decisionNumber) * timePerDecision;
                endTime = new Date(new Date().getTime() + remainingTime);
            }

            process.stdout.clearLine();
            process.stdout.cursorTo(0);
            process.stdout.write(
                'Requesting '+decisions[decisionNumber][0]+', ' + decisionNumber + ' of ' + (decisions.length - 1) + '. Projected end = ' + endTime
            );

            var response = await fetch(
                'http://supremecourt.ohio.gov/pdf_viewer/pdf_viewer.aspx?pdf=' + decisions[decisionNumber][1],
                fetchInit
            );
            if (!response.ok) throw new Error(`unexpected response ${response.statusText}`);

            process.stdout.clearLine();
            process.stdout.cursorTo(0);
            process.stdout.write(
                'Processing '+decisions[decisionNumber][0]+', ' + decisionNumber + ' of ' + (decisions.length - 1) + '. Projected end = ' + endTime
            );

            await streamPipeline(
                response.body,
                fse.createWriteStream(
                    './decisions/' + decisions[decisionNumber][0].slice(0, 4) + '/' + decisions[decisionNumber][0] + '.pdf'
                )
            );
        }
    } catch (error) {
        console.error('\nERROR!', error);
    }
    console.log('\nDONE!');
})();
