@echo off
echo running cmd script[%0]
echo within directory=[%~dp0]

echo This the 2nd configuration file[setup-builtin-roles]

SET SETUP-BUILTIN-ROLES=

rem circuit breaker
IF NOT DEFINED DATAVERSE_SRC_ROOT (
    ECHO DATAVERSE_SRC_ROOT is not defined
    GOTO :onErrorExit
)


rem SET SERVER=http://localhost:8080/api
rem echo server[%SERVER%]


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


SET ROLES_MIME_TYPE=Content-type:application/json
echo roles mime type[%ROLES_MIME_TYPE%]

SET ROLES_DATA_PATH=data
echo roles file path[%ROLES_DATA_PATH%]

SET ROLES_API_PATH=admin/roles/
echo [%ROLES_API_PATH%]

SET ROLES_API_ENDPOINT=%DATAVERSE_API_ROOT%%ROLES_API_PATH%

echo [%ROLES_API_ENDPOINT%]


:: Setup the builtin roles
echo Setting up admin role

curl -H "%ROLES_MIME_TYPE%" -d @%ROLES_DATA_PATH%/role-admin.json %ROLES_API_ENDPOINT%
echo.
pause

echo Setting up file downloader role
curl -H "%ROLES_MIME_TYPE%" -d @%ROLES_DATA_PATH%/role-filedownloader.json %ROLES_API_ENDPOINT%
echo.
pause

echo Setting up full contributor role
curl -H "%ROLES_MIME_TYPE%" -d @%ROLES_DATA_PATH%/role-fullContributor.json %ROLES_API_ENDPOINT%
echo.
pause

echo Setting up dv contributor role
curl -H "%ROLES_MIME_TYPE%" -d @%ROLES_DATA_PATH%/role-dvContributor.json %ROLES_API_ENDPOINT%
echo.
pause

echo Setting up ds contributor role
curl -H "%ROLES_MIME_TYPE%" -d @%ROLES_DATA_PATH%/role-dsContributor.json %ROLES_API_ENDPOINT%
echo.
pause

echo Setting up editor role
curl -H "%ROLES_MIME_TYPE%" -d @%ROLES_DATA_PATH%/role-editor.json %ROLES_API_ENDPOINT%
echo.
pause

echo Setting up curator role
curl -H "%ROLES_MIME_TYPE%" -d @%ROLES_DATA_PATH%/role-curator.json %ROLES_API_ENDPOINT%
echo.
pause

echo "Setting up member role"
curl -H "%ROLES_MIME_TYPE%" -d @%ROLES_DATA_PATH%/role-member.json  %ROLES_API_ENDPOINT%
echo.


echo leaving the api directory
popd

echo exiting cmd script[%0]
SET SETUP-BUILTIN-ROLES=Y
echo SETUP-BUILTIN-ROLES=[%SETUP-BUILTIN-ROLES%]

goto :eof

:onErrorExit
rem popd?
echo command file[%0] failed
echo SETUP-BUILTIN-ROLES=[%SETUP-BUILTIN-ROLES%]

Exit /B 1
