# oh-sup-ct-clerk-docket-crawler

The Ohio Supreme Court Clerk Docket Crawler is an initiative of [Ohio Supreme Court "Reasons Therefor" Research](https://ohio-supreme-court-reasons-therefor.github.io/?q=%22together%20with%20the%20reasons%20therefor%22).  The crawler collects data that facilitates research into the history and observance of the mandate in the Ohio Constitution's Article IV, Section 2(C): "The decisions in all cases in the Supreme Court shall be reported together with the reasons therefor."

The Crawler is configured to crawl the Ohio Supreme Court Clerk's [online docket database](https://www.supremecourt.ohio.gov/Clerk/ecms/#/search) and save its data locally.  *(At a technical level, what the core code does is (1) retrieve JSON formatted case data through HTTPS and an ASP.NET interface that is present within the Clerk's set of pages and (2) save then import that data into a SQLite database.)*

A copy of the collected data has been uploaded to Kaggle.  See <https://www.kaggle.com/jfreed/ohio-supreme-court-dockets>.

## Setup

* Install Node.js
* Fork and/or clone this repository locally.
* Open a terminal, change to this repository's local folder, and execute `npm ci` to clean and install required node modules.

## Extraction

Execute these steps to extract data from the Ohio Supreme Court Clerk's online docket database and save that data into local files.

* Verify or revise the contents of the `1-docket-crawler-params.json` file. The earliest year's data that can be downloaded at this time is 1985.
* Open a terminal, change to this repository's local folder, and execute `node 1-docket-crawler.js`.  Downloading 1985 through 2021 has taken between 12 to 13 hours, and the results are about 280 MB in size. The data is saved into .txt files, by year, in the ./tmp sub-folder.

## Transformation and Load

Execute these steps to transform the previous step's saved data from JSON to CSV and load it into a database.

* If you have not previously done so, execute the following command:  `npm install generate-schema -g`
* Open a terminal, change to this repository's local folder, then execute the following commands.  *(Note: The .bat files are meant to be executed on a Windows computer. If you do not have a Windows computer, then just review the .bat files and execute their pertinent commands in a manner appropriate for your computer.)*
  * `node 2-check-data-files-json.js`
  * `3-concat-files.bat`
  * `4-export-to-csv.bat`
* If you have not previously done so, install SQLite and ensure `sqlite` is in your path.
* Open a terminal, change to this repository's local folder, then execute the following commands:
  * `5-set-up-database.bat`
  * `6-import-to-database.bat`

## Analysis

Analyze the data in the database as desired.  For example SQL statements, see the file `7-analyze.sql`.

To open the SQLite database, consider using the program DBeaver (<https://dbeaver.io/>).

## Tech Stack

This repository contains Node.js code, MS Windows command line .bat(ch) files, and a SQLite database and related SQL. The code downloads JSON-formatted data across HTTPS, converts the data to CSV files, and imports it into that SQLite database. Because this work regards data analysis, Python instead of Node.js and .bat may be preferable if there is ever good reason to refactor the code. (Python was used in the downstream Kaggle work at <https://www.kaggle.com/jfreed/ohio-supreme-court-docket-words-phrases>.)

## Disclaimer

This respository and the referenced research are private and not affiliated with the [Supreme Court of Ohio](https://supremecourt.ohio.gov).
