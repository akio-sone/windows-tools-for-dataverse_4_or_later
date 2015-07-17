@echo off
echo running cmd script[%0]
echo within directory=[%~dp0]

ECHO This is the 1st configuration file: setup-dtasetfiels batch file

SET SETUP-DATASETFIELDS=

rem circuit breaker
IF NOT DEFINED DATAVERSE_SRC_ROOT (
    ECHO DATAVERSE_SRC_ROOT is not defined
    GOTO :onErrorExit
) else (
    echo DATAVERSE_SRC_ROOT=[%DATAVERSE_SRC_ROOT%]
)

if not defined DATAVERSE_API_DIR (
    set  DATAVERSE_API_DIR=%DATAVERSE_SRC_ROOT%scripts\api\
    echo use the default=[%DATAVERSE_API_DIR%] for dataverse api directory
    
    
    
) else (
    echo DATAVERSE_API_DIR=[%DATAVERSE_API_DIR%] is used for dataverse api directory
)

echo moving to the api directory
pushd %DATAVERSE_API_DIR%

echo running 1st batch file[setup-datasetfields]
if not defined DATAVERSE_API_ROOT (
    SET DATAVERSE_API_ROOT=http://%DATAVERSE_HOST%:%DATAVERSE_PORT%/api/
)
echo dataverse api root=[%DATAVERSE_API_ROOT%]
rem SET API_URL=http://localhost:8080/api/

SET DATASET_FIELDS_MIME_TYPE=Content-type: text/tab-separated-values
echo datasetfields mime type=[%DATASET_FIELDS_MIME_TYPE%]


SET METADATA_PATH=data/metadatablocks/
echo metadatablock file path=[%METADATA_PATH%]


SET DF_API_PATH=admin/datasetfield/load
ECHO DF_API_PATH=[%DF_API_PATH%]

SET DF_API_ENDPOINT=%DATAVERSE_API_ROOT%%DF_API_PATH%
ECHO DF_API_ENDPOINT=[%DF_API_ENDPOINT%]

curl %DF_API_ENDPOINT%NAControlledVocabularyValue
echo.
pause

curl %DF_API_ENDPOINT% -X POST --data-binary @%METADATA_PATH%citation.tsv       -H "%DATASET_FIELDS_MIME_TYPE%"
echo. 
pause

curl %DF_API_ENDPOINT% -X POST --data-binary @%METADATA_PATH%geospatial.tsv     -H "%DATASET_FIELDS_MIME_TYPE%"
echo. 
pause

curl %DF_API_ENDPOINT% -X POST --data-binary @%METADATA_PATH%social_science.tsv -H "%DATASET_FIELDS_MIME_TYPE%"
echo. 
pause

curl %DF_API_ENDPOINT% -X POST --data-binary @%METADATA_PATH%astrophysics.tsv   -H "%DATASET_FIELDS_MIME_TYPE%"
echo. 
pause

curl %DF_API_ENDPOINT% -X POST --data-binary @%METADATA_PATH%biomedical.tsv     -H "%DATASET_FIELDS_MIME_TYPE%"
echo. 
pause

curl %DF_API_ENDPOINT% -X POST --data-binary @%METADATA_PATH%journals.tsv       -H "%DATASET_FIELDS_MIME_TYPE%"
echo. 
pause

echo leaving the api directory
popd


echo exiting cmd script[%0]
SET SETUP-DATASETFIELDS=Y

echo SETUP-DATASETFIELDS=[%SETUP-DATASETFIELDS%]

goto :eof

:onErrorExit
rem popd?
echo command file[%0] failed
echo SETUP-DATASETFIELDS=[%SETUP-DATASETFIELDS%]

Exit /B 1

