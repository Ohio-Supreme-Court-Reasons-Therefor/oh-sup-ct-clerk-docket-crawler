# oh-sup-ct-data-getter

The Ohio Supreme Court Clerk Docket Getter is an initiative of [Ohio Supreme Court "Reasons Therefor" Research](https://ohio-supreme-court-reasons-therefor.github.io/?q=%22together%20with%20the%20reasons%20therefor%22).  The crawler collects data that facilitates research into the history and observance of the mandate in the Ohio Constitution's Article IV, Section 2(C): "The decisions in all cases in the Supreme Court shall be reported together with the reasons therefor."

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

update case_law_data set
citations = json_extract(raw_data,'$.citations'),
docket_number = json_extract(raw_data,'$.docket_number'),
decision_date = json_extract(raw_data,'$.decision_date'),
head_matter = json_extract(raw_data,'$.casebody.data.head_matter'),
opinions = json_extract(raw_data,'$.casebody.data.opinions')

According to case.law, it appears that simple incremental integers were used for docket numbers through 1967.
In 1968, the docket number format was changed, and they began to be reported as 'YY-#', e.g. '68-1'.
In 2002, the docket numbers began to be reported with four digit years, 'CCYY-#', e.g. '2001-1'.
select decision_date, citations, docket_number, docket_number_length, docket_number_type
,iif(instr(docket_number,' ')>0,'text','no space')
,iif(instr(docket_number,'-')>0,'text','no dash')
,abs(docket_number)
from (select decision_date, 
      citations, 
      docket_number,
      length(docket_number) docket_number_length, 
      iif(instr(docket_number,' ')>0,'text',iif(instr(docket_number,'-')>0,'text',iif(abs(docket_number)=0,'text','integer'))) docket_number_type
      from (select decision_date, citations, trim(replace(replace(replace(replace(docket_number,'No. ',''),'No ',''),'Nos. ',''),'and ','')) docket_number from case_law_data))
where docket_number_length != 0
and docket_number_length || docket_number_type != '4integer'
and docket_number_length || docket_number_type != '5integer'
order by decision_date

According to the previous query of case.law data, a docket number was first reported for a decision made in 1865, specifically 3003 in 53 Ohio St. 646.
HOWEVER, date appears to be in error, because the surrounding cases were decided on the same date in 1895.

The first reported docket numbers appear to be No. 148 and No. 149 for Catharine Carder v. The Board of Commissioners of Fayette County
at 16 Ohio St. 354.  (case.law says 353, but the scan indicates 354)

The next reported docket numbers appear to be No. 18 and No. 21 for 20 Ohio St. 38 (1870), George D. Morgan & Co. v. Miller M. Spangler et al.; George D. Morgan & Co. v. Alvin Bronson et al.

After that, same volume, No. 365 and No. 167 for 20 Ohio St. 496 (1870).

So, the original pattern seems to be that unless two or more causes are in a single decision/opinion, the docket number was left out.

Clearly, there were more than 18 and 21 cases that preceded 20 Ohio St. 38 (1870), so those numbers must be specific to the year?



HOWEVER, if you go to the PDF scan of that "3003" case at 53 Ohio St. 646, you will see that
the surrounding cases also had reported docket numbers.  
Based on the volume's full PDF scan, it appears that docket numbers began to be reported in earnest with the section in that volume 
of "MEMORANDA OF Causes Decided During the Period Embraced in this Volume, Which Are Not Reported in Full."
The first such docket number was 2748.
That prompts a look at prior volumes.
52 is the same. No numbers for opinions; numbers for memoranda.
40 has no numbers for opinions, and has no memoranda at all.
46 is the same as 40.
49 is the same as 40.
1893 50 is the same as 40.
1894 51 changes!  New reporter.  Levi J. Burgess died in May and E.O. Randall took over.
        xi   "Table of Cases Not Reported in Full" 561 "MEMORANDA OF Causes Decided During the Period Embraced in this Volume, Which Are Not Reported in Full."
                                                         Header: Memoranda of Causes not reported in full.
1895 52 vii  "Table of Cases Not Reported in Full" 603 "MEMORANDA OF Causes Decided During the Period Embraced in this Volume, Which Are Not Reported in Full."
                                                         Header: Memoranda of Causes not reported in full.
1895 53 xiii "Table of Cases Not Reported in Full" 635 "MEMORANDA OF Causes Decided During the Period Embraced in this Volume, Which Are Not Reported in Full."
                                                         Header: Memoranda of Causes not reported in full.
1896 54 xi   "Table of Cases Unreported"           611 "MEMORANDA OF Causes Decided During the Period Embraced in this Volume, Which Are Not Reported in Full."
                                                         Header: Memoranda of Causes not reported in full.
1896 55 xxv  "Table of Cases Unreported"           633 "MEMORANDA OF Causes Decided During the Period Embraced in this Volume, Which Are Not Reported in Full."
                                                         Header: Memoranda of Causes not reported in full.
1897 56 xiv  "Table of Cases Not Reported in Full" 725 "MEMORANDA OF Causes Decided During the Period Embraced in this Volume, Which Are Not Reported in Full."
                                                         Header: Memoranda of Causes not reported in full.
1898 57 vii  "Table of Cases Unreported"           627 "MEMORANDA OF Causes Decided During the Period Embraced in this Volume, Which Are Not Reported in Full."
                                                         Header: Memoranda of Causes not reported in full.
1898 58 vii  "Table of Cases Unreported"           689 "MEMORANDA OF Causes Decided During the Period Embraced in this Volume, Which Are Not Reported in Full."
                                                         Header: Memoranda of Causes not reported in full.
1898 59 xiv  "Table of Cases Not Reported in Full" 591 "MEMORANDA OF Causes Decided During the Period Embraced in this Volume, Which Are Not Reported in Full."
                                                         Header: Memoranda of Causes not reported in full.
1899 60 vii  "Table of Cases Unreported"           579 "MEMORANDA OF Causes Decided During the Period Embraced in this Volume, Which Are Not Reported in Full."
                                                         Header: Memoranda of Causes not reported in full.
1899 61 vii  "Table of Cases Not Reported in Full" 635 "MEMORANDA OF Causes Decided During the Period Embraced in this Volume, Which Are Not Reported in Full."
                                                         Header: Memoranda of Causes not reported in full.
1900 62 vii  "Table of Cases Not Reported in Full" 631 "MEMORANDA OF Causes Decided During the Period Embraced in this Volume, Which Are Not Reported in Full."
                                                         Header: Memoranda of Causes not reported in full.
1900 63 vii  "Table of Cases Not Reported in Full" 557 "MEMORANDA OF Causes Decided During the Period Embraced in this Volume, Which Are Not Reported in Full."
                                                         Header: Memoranda of Causes not reported in full.

??? -- are some of the cases not reported in full then reported in full at a later point? in the next volume?

1901 64 vii  "Table of Cases Not Reported in Full" 547 "MEMORANDA OF Causes Decided During the Period Embraced in this Volume, Which Are Not Reported in Full."
                                                         Header: Memoranda of Causes not reported in full.
1901 65 vii  "Cases Not Reported in Full"          555 "MEMORANDA OF Causes Decided During the Period Embraced in this Volume, Which Are Not Reported in Full."
                                                         Header: Memoranda of Causes not reported in full.
       fn on page 555:  *The reported eases in this volume begin with June 4, 1901.
                        The unreported cases from that date to June 25, 1901, will he
                        found in 64 Ohio St.—Reporter.*The reported eases in this volume begin with June 4, 1901.
                        The unreported cases from that date to June 25, 1901, will he
                        found in 64 Ohio St.—Reporter.
1902 66 vii    "Table of Cases Not Reported in Full" 633 "MEMORANDA OF Causes Decided During the Period Embraced in this Volume, Which Are Not Reported in Full."
                                                         Header: Memoranda of Causes not reported in full.
1902 67 xxxvii "Table of Cases Not Reported in Full" 497 "MEMORANDA OF Causes Decided During the Period Embraced in this Volume, Which Are Not Reported in Full."
                                                         Header: Memoranda of Causes not reported in full.
1903 68 ix     "Cases Not Reported in Full"          645 "MEMORANDA OF Causes Decided During the Period Embraced in this Volume, Which Are Not Reported in Full."
       State ex rel. Moffatt v. Gotchell. Demurrer to petition overruled and peremptory writ of mandamus awarded.  Big or embarrassing case???
                                                         Header: Memoranda of Causes not reported in full.
1903 69 xi     "Cases Not Reported in Full"          531 "MEMORANDA OF Causes Decided During the Period Embraced in this Volume, Which Are Not Reported in Full."
                                                         Header: Memoranda of Causes not reported in full.
1904 70 ix     "Cases Not Reported in Full"          421 "MEMORANDA OF Causes Decided During the Period Embraced in this Volume, Which Are Not Reported in Full."
                                                         Header: UNREPORTED CASES (Memoranda of Causes not reported in full.)
1904 71 ix     "Table of Cases Not Reported in Full" 471 "MEMORANDA OF Causes Decided During the Period Embraced in this Volume, Which Are Not Reported in Full."
                                                         Header: UNREPORTED CASES (Memoranda of Causes not reported in full.)
1905 72 xi     "Table of Cases Not Reported in Full" 593 "MEMORANDA OF Causes Decided During the Period Embraced in this Volume, Which Are Not Reported in Full."
                                                         Header: UNREPORTED CASES (Memoranda of Causes not reported in full.)
1906 73 xxxvii "Table of Cases Not Reported in Full" 333 "MEMORANDA OF Causes Decided During the Period Embraced in this Volume, Which Are Not Reported in Full."
                                                         Header: UNREPORTED CASES (Memoranda of Causes not reported in full.)
1906 74 xi     "Table of Cases Not Reported in Full" 423 "MEMORANDA OF Causes Decided During the Period Embraced in this Volume, Which Are Not Reported in Full."
                                                         Header: UNREPORTED CASES (Memoranda of Causes not reported in full.)
1907 75 xiii   "Table of Cases Not Reported in Full" 563 "MEMORANDA OF Causes Decided During the Period Embraced in this Volume, Which Are Not Reported in Full."
                                                         Header: UNREPORTED CASES (Memoranda of Causes not reported in full.)
1907 76 xi     "Table of Cases Not Reported in Full" 561 "MEMORANDA OF Causes Decided During the Period Embraced in this Volume, Which Are Not Reported in Full."
                                                         Header: UNREPORTED CASES (Memoranda of Causes not reported in full.)
1908 77 xi     "Table of Cases Not Reported in Full" 595 "MEMORANDA OF Causes Decided During the Period Embraced in this Volume, Which Are Not Reported in Full."
                                                         Header: UNREPORTED CASES (Memoranda of Causes not reported in full.)
1908 78 xi     "Table of Cases Not Reported in Full" 387 "MEMORANDA OF Causes Decided During the Period Embraced in this Volume, Which Are Not Reported in Full."
                                                         Header: UNREPORTED CASES (Memoranda of Causes not reported in full.)
1909 79 xi     "Table of Cases Not Reported in Full" 429 "MEMORANDA OF Causes Decided Without Opinion During the Period Embraced in this Volume, Which Are Not Reported in Full."
                                                         Header: UNREPORTED CASES (Case Reported Without Opinion)
1909 80 xi     "Table of Cases Not Reported in Full" 701 "MEMORANDA OF Causes Decided Without Opinion During the Period Embraced in this Volume, Which Are Not Reported in Full."
                                                         Header: UNREPORTED CASES (Case Reported Without Opinion)

                    * note the "IN RE CHARLES A. THATCHER" case !  Big/embarrasing case or links to such? regarding railroad/streetcar injuries and judges?
                      See 1912 related case here:  https://books.google.com/books?id=lzMtAQAAMAAJ&pg=PA274&lpg=PA274&dq=IN+RE+CHARLES+A.+THATCHER+ohio+railroad+OR+street-car&source=bl&ots=HT8n75STYl&sig=ACfU3U1IOolJmh5klW2l6JiMXMLp0Cs6ew&hl=en&sa=X&ved=2ahUKEwjujs2VtKrwAhVPZ80KHbo3Cc8Q6AEwCHoECAgQAw#v=onepage&q=IN%20RE%20CHARLES%20A.%20THATCHER%20ohio%20railroad%20OR%20street-car&f=false

1910 81 xi     "Table of Cases Not Reported in Full"     481 "MEMORANDA OF Causes Decided Without Opinion During the Period Embraced in this Volume, Which Are Not Reported in Full."
                                                             Header: MEMORANDA CASES (Case Reported Without Opinion)
1910 82 xi     "Table of Cases Not Reported in Full"     387 "MEMORANDA OF Causes Decided Without Opinion During the Period Embraced in this Volume, Which Are Not Reported in Full."
                                                             Header: MEMORANDA CASES (Case Reported Without Opinion)
1911 83 xi     "Table of Cases Reported Without Opinion" 441 "MEMORANDA OF Causes Decided Without Opinion During the Period Embraced in this Volume, Which Are Not Reported in Full."
                                                             Header: MEMORANDA CASES (Case Reported Without Opinion)
1911 84 xi     "Table of Cases Reported Without Opinion" 439 "MEMORANDA OF Causes Decided Without Opinion During the Period Embraced in this Volume, Which Are Not Reported in Full."
                                                             Header: MEMORANDA CASES (Case Reported Without Opinion)
1912 85 xi     "Table of Cases Reported Without Opinion" 433 "MEMORANDA OF Causes Decided Without Opinion During the Period Embraced in this Volume, Which Are Not Reported in Full."
                                                             Header: MEMORANDA CASES (Case Reported Without Opinion)
1912 86 xi     "Table of Cases Reported Without Opinion" 305 "MEMORANDA OF Causes Decided Without Opinion During the Period Embraced in this Volume, Which Are Not Reported in Full."
                                                             Header: MEMORANDA CASES (Case Reported Without Opinion)
1913 87 xi     "Table of Cases Reported Without Opinion" 457 "MEMORANDA OF Causes Decided Without Opinion During the Period Embraced in this Volume, Which Are Not Reported in Full."
                                                             Header: MEMORANDA CASES (Case Reported Without Opinion)
1913 88 xi     "Table of Cases Reported Without Opinion" 525 "MEMORANDA OF Causes Decided Without Opinion During the Period Embraced in this Volume, Which Are Not Reported in Full."
                                                             Header: MEMORANDA CASES (Case Reported Without Opinion)

                     * The very first such memoranda involved had the judgment reversed, but no reasons therefor were reported.
                       THe same happened on page 537, No. 13044. Furste v. The Henderson Lithographing Co. Decided March 25, 1913

1914 89 xiii   "Table of Cases Reported Without Opinion" 403 "MEMORANDA OF Causes Decided Without Opinion During the Period Embraced in this Volume, Which Are Not Reported in Full."
                                                             Header: MEMORANDA CASES (Case Reported Without Opinion)
1914 90 xiii   "Table of Cases Reported Without Opinion" 381 "MEMORANDA OF Causes Decided Without Opinion During the Period Embraced in this Volume, Which Are Not Reported in Full."
                                                             Header: MEMORANDA CASES (Case Reported Without Opinion)
1915 91 xiii   "Table of Cases Reported Without Opinion" 365 "MEMORANDA OF Causes Decided Without Opinion During the Period Embraced in this Volume, Which Are Not Reported in Full."
                                                             Header: MEMORANDA CASES (Case Reported Without Opinion)
1915 92 xv     "Table of Cases Reported Without Opinion" 509 "MEMORANDA OF Causes Decided Without Opinion During the Period Embraced in this Volume, Which Are Not Reported in Full."
                                                             Header: MEMORANDA CASES (Case Reported Without Opinion)
1915 93 xix    "Table of Cases Reported Without Opinion" 493 "MEMORANDA OF Causes Decided Without Opinion During the Period Embraced in this Volume, Which Are Not Reported in Full."
                                                             Header: MEMORANDA CASES (Case Reported Without Opinion)
               * table is only 2 pages long, which is really short compared to previous volumes
1916  94       * see new rule of practice, Rule X, page xi  !!!!!!!!!!!!!!!!!!
               Now there is just a "Table of Cases Reported", not two tables, one for With Opinion and one for Without Opinion
                                                         458 Header: "MEMORANDA CASES" (Cases Reported Without Opinion).  Just two cases.
1917  95       No separate table.                        415 Header: "MEMORANDA CASES" (Without Opinion).  Just two cases.
1917  96       No separate table.                        609 "MEMORANDA OF Causes Decided Without Opinion During the Period Embraced in this Volume"
                                                             Header: MEMORANDA CASES (Case Reported Without Opinion)
1917  96       No separate table.                        609 "MEMORANDA OF Causes Decided Without Opinion During the Period Embraced in this Volume"
                                                             Header: MEMORANDA CASES (Case Reported Without Opinion)
1918  97       No separate table.                        346 Header: (Cases Reported Without Opinion)  Two cases.
1918  98       No separate table.                            No separately titled or headed section.
1919  99       No separate table.                            No separately titled or headed section.
1919 100       No separate table.                        548 Header: (Case Reported Without Opinion)  One case.
               * Reporter E.O. Randall is noted as having died.
1920 101       No separate table.                            No separately titled or headed section.
               * Memorial for E.O. Randall on page xliii.  No mention of any changes to the reporter's role during his tenure.
1921 102       No separate table.                            No separately titled or headed section.
               * Contains Wanamaker's reference to "reasons therefor" at 651.
1921 103       No separate table.                            No separately titled or headed section.
1922 104       No separate table.                            No separately titled or headed section.
1922 105       No separate table.                            No separately titled or headed section.
1922 106       No separate table.                            No separately titled or headed section.
1923 107       No separate table.                            No separately titled or headed section.
               * 471:  "Nor does it follow, because the decision of the circuit court was affirmed in that case by
                        this court without opinion, that, in the absence of specific declaration that effect, this
                        court adopted the reasoning of the court below; such affirmance being effective only to
                        sustain the judgment and to make the enunciation by the court below the law of the case.
1923 108       No separate table.                            No separately titled or headed section.
1924 109       No separate table.                            No separately titled or headed section.
1924 110       * This is when the case.law scans start to no longer include text outside of the decisions and page numbers. No title page, no tables pages, etc.












The vast majority of cases have one citation type of type 'majority'. 
It's only in the past few decades that the "number-Ohio-number" webcite started to be used.
select count(*), COALESCE( json_extract(citations,'$[0].type'),'')
|| '|' || COALESCE(json_extract(citations,'$[1].type'),'')
from case_law_data
group by  COALESCE( json_extract(citations,'$[0].type'),'')

The vast majority of cases have one opinion of type 'majority'
select count(*), COALESCE( json_extract(opinions,'$[0].type'),'')
|| '|' || COALESCE(json_extract(opinions,'$[1].type'),'')
|| '|' || COALESCE(json_extract(opinions,'$[2].type'),'')
|| '|' || COALESCE(json_extract(opinions,'$[3].type'),'')
|| '|' || COALESCE(json_extract(opinions,'$[4].type'),'')
|| '|' || COALESCE(json_extract(opinions,'$[5].type'),'')
|| '|' || COALESCE(json_extract(opinions,'$[6].type'),'')
|| '|' || COALESCE(json_extract(opinions,'$[7].type'),'')
from case_law_data
group by  COALESCE( json_extract(opinions,'$[0].type'),'')
|| '|' || COALESCE(json_extract(opinions,'$[1].type'),'')
|| '|' || COALESCE(json_extract(opinions,'$[2].type'),'')
|| '|' || COALESCE(json_extract(opinions,'$[3].type'),'')
|| '|' || COALESCE(json_extract(opinions,'$[4].type'),'')
|| '|' || COALESCE(json_extract(opinions,'$[5].type'),'')
|| '|' || COALESCE(json_extract(opinions,'$[6].type'),'')
|| '|' || COALESCE(json_extract(opinions,'$[7].type'),'')

159 cases do not have the first opinion type being 'majority'
select raw_data from case_law_data where COALESCE( json_extract(opinions,'$[0].type'),'')
|| '|' || COALESCE(json_extract(opinions,'$[1].type'),'')
|| '|' || COALESCE(json_extract(opinions,'$[2].type'),'')
|| '|' || COALESCE(json_extract(opinions,'$[3].type'),'')
|| '|' || COALESCE(json_extract(opinions,'$[4].type'),'')
|| '|' || COALESCE(json_extract(opinions,'$[5].type'),'')
|| '|' || COALESCE(json_extract(opinions,'$[6].type'),'')
|| '|' || COALESCE(json_extract(opinions,'$[7].type'),'') not like 'majority%'

Items with opinions of less than 10,000 characters and their head_matters may be grouped according to their lengths 
that are rounded to the nearest 100 characters.
select round(length(opinions)/100)*100 opinionlen, round(length(head_matter)/100)*100 headmatterlen,  count(*) 
from case_law_data 
where length(opinions) < 10000
group by round(length(opinions)/100)*100,round(length(head_matter)/100)*100
order by round(length(opinions)/100)*100 desc, round(length(head_matter)/100)*100 desc, count(*) desc

2,061 items have opinions and head_matter of less than 50 characters
All of them are from 1988 and after.
Not all of them are dispositive decisions. Some are about motions and rehearings.
select decision_date,citations,head_matter, opinions
from case_law_data 
where round(length(opinions)/100)*100 = 0
and round(length(head_matter)/100)*10 = 0
order by decision_date desc






## Analysis

Analyze the data in the database as desired.  For example SQL statements, see the file `7-analyze.sql`.

To open the SQLite database, consider using the program DBeaver (<https://dbeaver.io/>).







## Tech Stack

This repository contains Node.js code, MS Windows command line .bat(ch) files, and a SQLite database and related SQL. The code downloads JSON-formatted data across HTTPS, converts the data to CSV files, and imports it into that SQLite database. Because this work regards data analysis, Python instead of Node.js and .bat may be preferable if there is ever good reason to refactor the code. (Python was used in the downstream Kaggle work at <https://www.kaggle.com/jfreed/ohio-supreme-court-docket-words-phrases>.)

## Disclaimer

This respository and the referenced research are private and not affiliated with the [Supreme Court of Ohio](https://supremecourt.ohio.gov).
