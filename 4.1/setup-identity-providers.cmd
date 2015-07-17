@echo off
echo running cmd script[%0]
echo within directory=[%~dp0]


echo This is the 3rd configuration file: setup-identity-providers

SET SETUP-IDENTITY-PROVIDERS=


rem circuit breaker
IF NOT DEFINED DATAVERSE_SRC_ROOT (
    ECHO DATAVERSE_SRC_ROOT is not defined
    GOTO :onErrorExit
)


REM SET SERVER=http://localhost:8080/api
REM echo server[%SERVER%]


if not defined DATAVERSE_API_DIR (
    set DATAVERSE_API_DIR=%DATAVERSE_SRC_ROOT%scripts\api\
    echo use the default[%DATAVERSE_API_DIR%] for dataverse api directory
) else (
    echo DATAVERSE_API_DIR[%DATAVERSE_API_DIR%] is used for dataverse api directory
)
echo moving to the api directory
pushd %DATAVERSE_API_DIR%



SET DATAVERSE_API_ROOT=http://%DATAVERSE_HOST%:%DATAVERSE_PORT%/api/
echo dataverse api root[%DATAVERSE_API_ROOT%]


SET IDP_MIME_TYPE=Content-type:application/json
echo identity providers mime type[%IDP_MIME_TYPE%]

SET IDP_DATA_PATH=data/
echo identity providers file path[%IDP_DATA_PATH%]


SET IDP_API_PATH=admin/authenticationProviders/
ECHO IDP_API_PATH[%IDP_API_PATH%]

SET IDP_API_ENDPOINT=%DATAVERSE_API_ROOT%%IDP_API_PATH%
ECHO IDP_API_ENDPOINT[%IDP_API_ENDPOINT%]


:: Setup the authentication providers
echo Setting up internal user provider
curl -H "%IDP_MIME_TYPE%" -d @%IDP_DATA_PATH%aupr-builtin.json %IDP_API_ENDPOINT%
echo. 
pause

echo Setting up echo providers
curl -H "%IDP_MIME_TYPE%" -d @%IDP_DATA_PATH%aupr-echo.json %IDP_API_ENDPOINT%
echo. 
pause

curl -H "%IDP_MIME_TYPE%" -d @%IDP_DATA_PATH%aupr-echo-dignified.json %IDP_API_ENDPOINT%
echo. 
pause

echo end of setup-identity-providers


echo leaving the api directory
popd


echo exiting cmd script[%0]
SET SETUP-IDENTITY-PROVIDERS=Y
echo SETUP-IDENTITY-PROVIDERS=[%SETUP-IDENTITY-PROVIDERS%]

goto :eof

:onErrorExit

echo command file[%0] failed
echo SETUP-IDENTITY-PROVIDERS=[%SETUP-IDENTITY-PROVIDERS%]


Exit /B 1
