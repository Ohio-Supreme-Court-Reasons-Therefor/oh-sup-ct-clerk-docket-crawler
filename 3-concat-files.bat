@ECHO.Copying all the docket crawler's tmp\data*.txt files into one data\all.txt file... 

ECHO.[{}>tmp\data0000.txt
ECHO.]>tmp\data9999.txt

COPY /B tmp\data*.txt tmp\all.txt

DEL /Q tmp\data0000.txt
DEL /Q tmp\data9999.txt


@ECHO.Generating a JSON schema for the data\all.txt file... 

generate-schema tmp\all.txt > tmp\schema.json
