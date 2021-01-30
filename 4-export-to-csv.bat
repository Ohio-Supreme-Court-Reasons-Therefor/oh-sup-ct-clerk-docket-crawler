@ECHO.

@ECHO.=-=-= EXPORTING CASE INFO... =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
ECHO.ID,CaseNumber,Caption,DateFiled,Status,CaseType,PriorJurisdiction,BadResponseText > data\caseinfo.csv
.\node_modules\node-jq\bin\jq -r ".[] | (.CaseInfo[]? | [.ID?,.CaseNumber?,.Caption?,.DateFiled?,.Status?,.CaseType?,.PriorJurisdiction?,.BadResponseText?]) | @csv" data\all.txt >> data\caseinfo.csv
@IF "%ERRORLEVEL%" NEQ "0" ECHO..=-=-= ERROR! Stopping exports because error level is not zero! ERRORLEVEL=[%ERRORLEVEL%]! =-=-= & GOTO :EOF
@ECHO.
@ECHO.

@ECHO.=-=-= EXPORTING CASE JURISDICTION INFO... =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
ECHO.CaseNumber,ID,JurisdictionDescription,Code,Type,DateFiled,DocumentName,FilingParties > data\casejurisdiction.csv
.\node_modules\node-jq\bin\jq -r ".[] | [.CaseInfo?.CaseNumber] + (.CaseJurisdiction? | [.ID,.Description,.Code,.Type,.DateFiled,.DocumentName,.FilingParties]) | @csv" data\all.txt >> data\casejurisdiction.csv
@IF "%ERRORLEVEL%" NEQ "0" ECHO..=-=-= ERROR! Stopping exports because error level is not zero! ERRORLEVEL=[%ERRORLEVEL%]! =-=-= & GOTO :EOF
@ECHO.
@ECHO.

@ECHO.=-=-= EXPORTING DOCKET ITEMS... =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
ECHO.CaseNumber,ID,DocketItemDescription,Code,Type,DateFiled,DocumentName,FilingParties > data\docketitems.csv
.\node_modules\node-jq\bin\jq -r ".[] | [.CaseInfo?.CaseNumber] + (.DocketItems[]? | [.ID,.Description,.Code,.Type,.DateFiled,.DocumentName,.FilingParties]) | @csv" data\all.txt >> data\docketitems.csv
@IF "%ERRORLEVEL%" NEQ "0" ECHO..=-=-= ERROR! Stopping exports because error level is not zero! ERRORLEVEL=[%ERRORLEVEL%]! =-=-= & GOTO :EOF
@ECHO.
@ECHO.

@ECHO.=-=-= EXPORTING DECISION ITEMS... =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
ECHO.CaseNumber,DecisionDescription,ReleaseDate,DisposesCase,DocumentName,FilingParties > data\decisionitems.csv
.\node_modules\node-jq\bin\jq -r ".[] | [.CaseInfo?.CaseNumber] + (.DecisionItems[]? | [.Description,.ReleaseDate,.DisposesCase,.DocumentName,.FilingParties]) | @csv" data\all.txt >> data\decisionitems.csv
@IF "%ERRORLEVEL%" NEQ "0" ECHO..=-=-= ERROR! Stopping exports because error level is not zero! ERRORLEVEL=[%ERRORLEVEL%]! =-=-= & GOTO :EOF
@ECHO.
@ECHO.

@ECHO.=-=-= EXPORTING PARTIES... =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
ECHO.CaseNumber,PartyName,ProSe,Type > data\parties.csv
.\node_modules\node-jq\bin\jq -r ".[] | [.CaseInfo?.CaseNumber] + (.Parties[]? | [.Name,.ProSe,.Type]) | @csv" data\all.txt >> data\parties.csv
@IF "%ERRORLEVEL%" NEQ "0" ECHO..=-=-= ERROR! Stopping exports because error level is not zero! ERRORLEVEL=[%ERRORLEVEL%]! =-=-= & GOTO :EOF
@ECHO.
@ECHO.

@ECHO.=-=-= EXPORTING ATTORNEYS... =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
ECHO.CaseNumber,PartyName,AttorneyName,AttorneyRegistrationNumber,CounselOfRecord > data\attorneys.csv
.\node_modules\node-jq\bin\jq -r ".[] | [.CaseInfo?.CaseNumber] + (.Parties[]? | [.Name] + (.Attorneys[]? | [.Name,.ARNumber,.CounselOfRecord])) | @csv" data\all.txt >> data\attorneys.csv
@IF "%ERRORLEVEL%" NEQ "0" ECHO..=-=-= ERROR! Stopping exports because error level is not zero! ERRORLEVEL=[%ERRORLEVEL%]! =-=-= & GOTO :EOF
@ECHO.
@ECHO.

@ECHO.
@ECHO.=-=-= DONE! (Execution of %~f0 is now complete.) =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
