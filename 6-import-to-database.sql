.import --csv --skip 1 data/case_info.csv case_info
.import --csv --skip 1 data/case_jurisdiction.csv case_jurisdiction
.import --csv --skip 1 data/docket_item.csv docket_item
.import --csv --skip 1 data/decision_item.csv decision_item
.import --csv --skip 1 data/party.csv party
.import --csv --skip 1 data/party_attorney.csv party_attorney
VACUUM;
.quit
