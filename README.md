# oh-sup-ct-clerk-docket-crawler

The Ohio Supreme Court Clerk Docket Crawler is a product of the [Ohio Supreme Court's Reasons Therefor](https://www.zotero.org/groups/2424402/ohio_supreme_courts_reasons_therefor) group.  The group researches the history and observance of the mandate in the Ohio Constitution's Article IV, Section 2(C): "The decisions in all cases in the Supreme Court shall be reported together with the reasons therefor."

The Crawler is configured to crawl the Ohio Supreme Court Clerk's [online docket database](https://www.supremecourt.ohio.gov/Clerk/ecms/#/search) and save its data into local files.

## Setup

* Install Node.js
* Fork and/or clone this repository locally.
* Open a terminal, change to the local repository directory, and execute `npm ci` to clean and install required node modules.

## Execution

* Verify or revise the contents of the `1-docket-crawler-params.json` file.
* Open a terminal, change to the local repository directory, and execute `node 1-docket-crawler.js`.  Downloading 1985 through 2021 has taken between 12 to 13 hours, and the results are about 280 MB in size.

## Processing

* Execute the following command if you have not previously done so:  `npm install generate-schema -g`
* Open a terminal, change to the `tmp` folder, then execute the following commands:
  * `node 2-check-data-files-json.js`
  * `3-concat-files.bat`
  * `4-export-to-csv.bat`
