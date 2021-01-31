@ECHO.
@CALL :CASE_INFO
@CALL :CASE_JURISDICTION
@CALL :DOCKET_ITEMS
@CALL :DECISION_ITEMS
@CALL :DISPOSITIVE_DECISION_ITEMS
@CALL :PARTIES
@CALL :ATTORNEYS
@ECHO.
@ECHO.=-=-= DONE! (Execution of %~f0 is now complete.) =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@GOTO :EOF

:CASE_INFO
@ECHO.=-=-= EXPORTING CASE INFO... =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
ECHO.id,case_number,caption,date_filed,status,case_type,prior_jurisdiction,bad_response_text> data\case_info.csv
.\node_modules\node-jq\bin\jq -r ".[] | select(.CaseInfo != null) | (.CaseInfo? | [.ID?,.CaseNumber?,.Caption?,.DateFiled?,.Status?,.CaseType?,.PriorJurisdiction?,.BadResponseText?]) | @csv" data\all.txt >> data\case_info.csv
@IF "%ERRORLEVEL%" NEQ "0" ECHO..=-=-= ERROR! Stopping exports because error level is not zero! ERRORLEVEL=[%ERRORLEVEL%]! =-=-= & EXIT
@ECHO.
@EXIT /B

:CASE_JURISDICTION
@ECHO.=-=-= EXPORTING CASE JURISDICTION INFO... =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
ECHO.case_number,jurisdiction_name,county,prior_decision_date,prior_case_numbers> data\case_jurisdiction.csv
.\node_modules\node-jq\bin\jq -r ".[] | select(.CaseInfo != null and .CaseJurisdiction != null) | [.CaseInfo?.CaseNumber] + (.CaseJurisdiction? | [.Name,.County,.PriorDecisionDate, (([(.PriorCaseNumbers[]?|.Number)])|join(\",\")) ]) | @csv" data\all.txt >> data\case_jurisdiction.csv
@IF "%ERRORLEVEL%" NEQ "0" ECHO..=-=-= ERROR! Stopping exports because error level is not zero! ERRORLEVEL=[%ERRORLEVEL%]! =-=-= & EXIT
@ECHO.
@EXIT /B

:DOCKET_ITEMS
@ECHO.=-=-= EXPORTING DOCKET ITEMS... =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
ECHO.case_number,id,description,code,type,date_filed,document_name,filing_parties> data\docket_item.csv
.\node_modules\node-jq\bin\jq -r ".[] | select(.CaseInfo != null and .DocketItems != null) | [.CaseInfo?.CaseNumber] + (.DocketItems[]? | [.ID,.Description,.Code,.Type,.DateFiled,.DocumentName,.FilingParties]) | @csv" data\all.txt >> data\docket_item.csv
@IF "%ERRORLEVEL%" NEQ "0" ECHO..=-=-= ERROR! Stopping exports because error level is not zero! ERRORLEVEL=[%ERRORLEVEL%]! =-=-= & EXIT
@ECHO.
@EXIT /B

:DECISION_ITEMS
@ECHO.=-=-= EXPORTING DECISION ITEMS... =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
ECHO.case_number,description,release_date,disposes_case,document_name,filing_parties> data\decision_item.csv
.\node_modules\node-jq\bin\jq -r ".[] | select(.CaseInfo != null and .DecisionItems != null) | [.CaseInfo?.CaseNumber] + (.DecisionItems[]? | [.Description,.ReleaseDate,(if .DisposesCase then 1 else 0 end),.DocumentName,.FilingParties]) | @csv" data\all.txt >> data\decision_item.csv
@IF "%ERRORLEVEL%" NEQ "0" ECHO..=-=-= ERROR! Stopping exports because error level is not zero! ERRORLEVEL=[%ERRORLEVEL%]! =-=-= & EXIT
@ECHO.
@EXIT /B

:DISPOSITIVE_DECISION_ITEMS
@ECHO.=-=-= EXPORTING DISPOSITIVE DECISION ITEMS... =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
.\node_modules\node-jq\bin\jq -r "[.[] | select(.DecisionItems != null) | [.CaseInfo?.CaseNumber] + (.DecisionItems[]? | select(.DisposesCase==true) | [.DocumentName]) | select(.[1]!=\"\")]" data\all.txt > data\dispositive_decision_items.json
@IF "%ERRORLEVEL%" NEQ "0" ECHO..=-=-= ERROR! Stopping exports because error level is not zero! ERRORLEVEL=[%ERRORLEVEL%]! =-=-= & EXIT
@ECHO.
@EXIT /B

:PARTIES
@ECHO.=-=-= EXPORTING PARTIES... =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
ECHO.case_number,party_name,pro_se,type> data\party.csv
.\node_modules\node-jq\bin\jq -r ".[] | select(.CaseInfo != null and .Parties != null) | [.CaseInfo?.CaseNumber] + (.Parties[]? | [.Name,(if .ProSe then 1 else 0 end),.Type]) | @csv" data\all.txt >> data\party.csv
@IF "%ERRORLEVEL%" NEQ "0" ECHO..=-=-= ERROR! Stopping exports because error level is not zero! ERRORLEVEL=[%ERRORLEVEL%]! =-=-= & EXIT
@ECHO.
@EXIT /B

:ATTORNEYS
@ECHO.=-=-= EXPORTING PARTY ATTORNEYS... =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
ECHO.case_number,party_name,attorney_name,attorney_registration_number,counsel_of_record> data\party_attorney.csv
.\node_modules\node-jq\bin\jq -r ".[] | select(.CaseInfo != null and .Parties != null) | [.CaseInfo?.CaseNumber] + (.Parties[]? | [.Name] + (.Attorneys[]? | [.Name,.ARNumber,(if .CounselOfRecord then 1 else 0 end)])) | @csv" data\all.txt >> data\party_attorney.csv
@IF "%ERRORLEVEL%" NEQ "0" ECHO..=-=-= ERROR! Stopping exports because error level is not zero! ERRORLEVEL=[%ERRORLEVEL%]! =-=-= & EXIT
@ECHO.
@EXIT /B
