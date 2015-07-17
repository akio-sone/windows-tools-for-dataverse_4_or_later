@echo off
echo running command script [%0]
echo within directory=[%~dp0]
echo This script delets the existing data from solr

SET RESET-SOLR=

echo checking env variables 
if not defined DATAVERSE_HOST (
    echo dataverse host is not defined
    echo dataverse host is set to localhost
    SET DATAVERSE_HOST=localhost
) else (
    echo dataverse host[%DATAVERSE_HOST%]
)

if not defined SOLR_PORT (
    echo solr port is not defined
    echo solr port is set to the factory default 8983
    SET SOLR_PORT=8983
) else (
    echo solr port[%SOLR_PORT%]
)

echo deleting all data from Solr
curl http://%DATAVERSE_HOST%:%SOLR_PORT%/solr/update/json?commit=true -H "Content-type: application/json" -X POST -d "{\"delete\": { \"query\":\"*:*\"}}"

echo exiting cmd script[%0]

SET RESET-SOLR=Y
echo RESET-SOLR=[%RESET-SOLR%]


goto :eof


:onErrorExit
echo command file[%0] failed
echo RESET-SOLR=[%RESET-SOLR%]
Exit /B 1

