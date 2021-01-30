ECHO.Exporting Case Info...
.\node_modules\node-jq\bin\jq -r ".[] | (.CaseInfo[] | [.ID?,.CaseNumber,.Caption?,.DateFiled?,.Status?,.CaseType?,.PriorJurisdiction?,.BadResponseText?]) | @csv" data\all.txt > data\caseinfo.csv
IF %ERRORLEVEL% NEQ "0" THEN GOTO :EOF

ECHO.Exporting Case Jurisdiction info...
.\node_modules\node-jq\bin\jq -r ".[] | [.CaseInfo.CaseNumber] + (.CaseJurisdiction? | [.ID,.Description,.Code,.Type,.DateFiled,.DocumentName,.FilingParties]) | @csv" data\all.txt > data\casejurisdiction.csv
IF %ERRORLEVEL% NEQ "0" THEN GOTO :EOF

ECHO.Exporting Docket Items...
.\node_modules\node-jq\bin\jq -r ".[] | [.CaseInfo.CaseNumber] + (.DocketItems[]? | [.ID,.Description,.Code,.Type,.DateFiled,.DocumentName,.FilingParties]) | @csv" data\all.txt > data\docketitems.csv
IF %ERRORLEVEL% NEQ "0" THEN GOTO :EOF

ECHO.Exporting Decision Items...
.\node_modules\node-jq\bin\jq -r ".[] | [.CaseInfo.CaseNumber] + (.DecisionItems[]? | [.Description,.ReleaseDate,.DisposesCase,.DocumentName,.FilingParties]) | @csv" data\all.txt > data\decisionitems.csv
IF %ERRORLEVEL% NEQ "0" THEN GOTO :EOF

ECHO.Exporting Parties...
.\node_modules\node-jq\bin\jq -r ".[] | [.CaseInfo.CaseNumber] + (.Parties[]? | [.Name,.ProSe,.Type]) | @csv" data\all.txt > data\parties.csv
IF %ERRORLEVEL% NEQ "0" THEN GOTO :EOF

ECHO.Exporting Attorneys...
.\node_modules\node-jq\bin\jq -r ".[] | [.CaseInfo.CaseNumber] + (.Parties[]? | [.Name] + (.Attorneys[]? | [.Name,.ARNumber,.CounselOfRecord])) | @csv" data\all.txt > data\attorneys.csv
IF %ERRORLEVEL% NEQ "0" THEN GOTO :EOF

