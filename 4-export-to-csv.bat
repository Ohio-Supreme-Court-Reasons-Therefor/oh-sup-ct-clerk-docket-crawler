@ECHO.
@CALL :CASE_INFO
@CALL :CASE_JURISDICTION
@CALL :DOCKET_ITEMS
@CALL :DECISION_ITEMS
@CALL :PARTIES
@CALL :ATTORNEYS
@ECHO.
@ECHO.=-=-= DONE! (Execution of %~f0 is now complete.) =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
GOTO :EOF

:CASE_INFO
@ECHO.=-=-= EXPORTING CASE INFO... =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
ECHO.ID,CaseNumber,Caption,DateFiled,Status,CaseType,PriorJurisdiction,BadResponseText> data\caseinfo.csv
.\node_modules\node-jq\bin\jq -r ".[] | select(.CaseInfo != null) | (.CaseInfo? | [.ID?,.CaseNumber?,.Caption?,.DateFiled?,.Status?,.CaseType?,.PriorJurisdiction?,.BadResponseText?]) | @csv" data\all.txt >> data\caseinfo.csv
@IF "%ERRORLEVEL%" NEQ "0" ECHO..=-=-= ERROR! Stopping exports because error level is not zero! ERRORLEVEL=[%ERRORLEVEL%]! =-=-= & EXIT
@ECHO.
@EXIT /B

:CASE_JURISDICTION
@ECHO.=-=-= EXPORTING CASE JURISDICTION INFO... =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
ECHO.Name,County,PriorDecisionDate,PriorCaseNumbers> data\casejurisdiction.csv
.\node_modules\node-jq\bin\jq -r ".[] | select(.CaseInfo != null and .CaseJurisdiction != null) | [.CaseInfo?.CaseNumber] + (.CaseJurisdiction? | [.Name,.County,.PriorDecisionDate, (([(.PriorCaseNumbers[]?|.Number)])|join(\",\")) ]) | @csv" data\all.txt >> data\casejurisdiction.csv
@IF "%ERRORLEVEL%" NEQ "0" ECHO..=-=-= ERROR! Stopping exports because error level is not zero! ERRORLEVEL=[%ERRORLEVEL%]! =-=-= & EXIT
@ECHO.
@EXIT /B

:DOCKET_ITEMS
@ECHO.=-=-= EXPORTING DOCKET ITEMS... =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
ECHO.CaseNumber,ID,DocketItemDescription,Code,Type,DateFiled,DocumentName,FilingParties> data\docketitems.csv
.\node_modules\node-jq\bin\jq -r ".[] | select(.CaseInfo != null and .DocketItems != null) | [.CaseInfo?.CaseNumber] + (.DocketItems[]? | [.ID,.Description,.Code,.Type,.DateFiled,.DocumentName,.FilingParties]) | @csv" data\all.txt >> data\docketitems.csv
@IF "%ERRORLEVEL%" NEQ "0" ECHO..=-=-= ERROR! Stopping exports because error level is not zero! ERRORLEVEL=[%ERRORLEVEL%]! =-=-= & EXIT
@ECHO.
@EXIT /B

:DECISION_ITEMS
@ECHO.=-=-= EXPORTING DECISION ITEMS... =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
ECHO.CaseNumber,DecisionDescription,ReleaseDate,DisposesCase,DocumentName,FilingParties> data\decisionitems.csv
.\node_modules\node-jq\bin\jq -r ".[] | select(.CaseInfo != null and .DecisionItems != null) | [.CaseInfo?.CaseNumber] + (.DecisionItems[]? | [.Description,.ReleaseDate,.DisposesCase,.DocumentName,.FilingParties]) | @csv" data\all.txt >> data\decisionitems.csv
@IF "%ERRORLEVEL%" NEQ "0" ECHO..=-=-= ERROR! Stopping exports because error level is not zero! ERRORLEVEL=[%ERRORLEVEL%]! =-=-= & EXIT
@ECHO.
@EXIT /B

:PARTIES
@ECHO.=-=-= EXPORTING PARTIES... =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
ECHO.CaseNumber,PartyName,ProSe,Type> data\parties.csv
.\node_modules\node-jq\bin\jq -r ".[] | select(.CaseInfo != null and .Parties != null) | [.CaseInfo?.CaseNumber] + (.Parties[]? | [.Name,.ProSe,.Type]) | @csv" data\all.txt >> data\parties.csv
@IF "%ERRORLEVEL%" NEQ "0" ECHO..=-=-= ERROR! Stopping exports because error level is not zero! ERRORLEVEL=[%ERRORLEVEL%]! =-=-= & EXIT
@ECHO.
@EXIT /B

:ATTORNEYS
@ECHO.=-=-= EXPORTING ATTORNEYS... =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
ECHO.CaseNumber,PartyName,AttorneyName,AttorneyRegistrationNumber,CounselOfRecord> data\attorneys.csv
.\node_modules\node-jq\bin\jq -r ".[] | select(.CaseInfo != null and .Parties != null) | [.CaseInfo?.CaseNumber] + (.Parties[]? | [.Name] + (.Attorneys[]? | [.Name,.ARNumber,.CounselOfRecord])) | @csv" data\all.txt >> data\attorneys.csv
@IF "%ERRORLEVEL%" NEQ "0" ECHO..=-=-= ERROR! Stopping exports because error level is not zero! ERRORLEVEL=[%ERRORLEVEL%]! =-=-= & EXIT
@ECHO.
EXIT /B
