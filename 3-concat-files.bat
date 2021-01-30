@ECHO.
@ECHO.Copying all the docket crawler's tmp\data*.txt files into one data\all.txt file...
@ECHO.

@ECHO.=-=-= Creating temporary files for the purpose of bookending the data json... =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@ECHO.
ECHO.[{}>tmp\data0000.txt
ECHO.]>tmp\data9999.txt
@ECHO.

@ECHO.=-=-= Copying the temporary files and data json files into one file... =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@ECHO.
COPY /B tmp\data*.txt data\all.txt
@ECHO.

@ECHO.=-=-= Deleting the temporary files... =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@ECHO.
DEL /Q tmp\data0000.txt
DEL /Q tmp\data9999.txt
@ECHO.

@ECHO.=-=-= Generating a JSON schema for the data\all.txt file... =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@ECHO.
CALL generate-schema data\all.txt > data\schema.json

@ECHO.
@ECHO.=-=-= DONE! (Execution of %~f0 is now complete.) =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
