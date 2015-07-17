@echo off
echo running cmd script[%0]
echo within directory=[%~dp0]


SET SETUP-ADMINKEY=


:: ----------------------------------------------------------------------------
echo Setting up the settings
echo Allow internal signup
rem warning +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
rem warning: the following commands must be executed in the DATAVERSE_API_DIR
rem warning +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



SET SERVER=http://localhost:8080/api/
echo SERVER=[%SERVER%]

SET SETTINGS_PATH=admin/settings/
ECHO SETTINGS_PATH=[%SETTINGS_PATH%]

SET SETTINGS_ENDPOINT=%SERVER%%SETTINGS_PATH%
echo SETTINGS_ENDPOINT=[%SETTINGS_ENDPOINT%]


if not defined DATAVERSE_API_DIR (
    set DATAVERSE_API_DIR=%DATAVERSE_SRC_ROOT%scripts\api\
    echo use the default[%DATAVERSE_API_DIR%] for dataverse api directory
) else (
    echo DATAVERSE_API_DIR[%DATAVERSE_API_DIR%] is used for dataverse api directory
)


echo moving to the api directory
pushd %DATAVERSE_API_DIR%





curl -X PUT -d yes "%SETTINGS_ENDPOINT%:AllowSignUp"
echo; 
curl -X PUT -d /dataverseuser.xhtml?editMode=CREATE "%SETTINGS_ENDPOINT%:SignUpUrl"
echo; 

curl -X PUT -d doi           "%SETTINGS_ENDPOINT%:Protocol"
echo; 

rem /FK2 becomes part of the storage path
curl -X PUT -d 10.5072/FK2   "%SETTINGS_ENDPOINT%:Authority"
echo; 
curl -X PUT -d EZID          "%SETTINGS_ENDPOINT%:DoiProvider"
echo; 
curl -X PUT -d /             "%SETTINGS_ENDPOINT%:DoiSeparator"
echo; 
curl -X PUT -d burrito        %SETTINGS_ENDPOINT%BuiltinUsers.KEY
echo; 
curl -X PUT -d empanada       %SETTINGS_ENDPOINT%:BlockedApiKey
echo;  
curl -X PUT -d localhost-only %SETTINGS_ENDPOINT%:BlockedApiPolicy
echo;
pause 

:: ---------------------------------------------------------------------------
rem set up admin user
rem adminResp=$(curl -s -H "Content-type:application/json" -X POST -d @data/user-admin.json "$SERVER/users?password=admin&key=burrito")
rem escape characters: & \ < > ^ |
rem curl -s -H "Content-type:application/json" -X POST -d @data/user-admin.json "%SERVER%/users?password=admin^&key=burrito"
rem jq -r .data.apiToken

echo Setting up the admin user and get adminKey
for /f "usebackq"  %%i in ( `curl -s -H "Content-type:application/json" -X POST -d @data/user-admin.json "%SERVER%builtin-users?password=admin&key=burrito" ^| jq -r .data.apiToken ` ) DO (
    echo %%i
    SET adminKey=%%i
)


echo adminKey[%adminKey%]

echo make admin as superuser
curl -X POST "%SERVER%admin/superuser/dataverseAdmin"
echo;
:: ---------------------------------------------------------------------------
rem set up the root dataverse

echo Setting up the root dataverse

echo checking adminKey first 

if not defined adminKey (
    echo admin key is not defined 
    goto :onErrorExit
) else (
    echo admin key is defined=[%adminKey%]
)

if [%adminKey%]==[] (
    echo admin key is empty
    goto :onErrorExit
) else (
    echo adminKey=[%adminKey%]
)


if [%adminKey%]==[null] (
    echo admin key is null
    goto :onErrorExit
) else (
    echo adminKey=[%adminKey%]
)

SET MIME_TYPE_JSON=Content-type:application/json
echo mime type to be used=[%MIME_TYPE_JSON%]


echo Setting up the root dataverse

curl -s -X POST -H "%MIME_TYPE_JSON%" -d @data/dv-root.json "%SERVER%dataverses/?key=%adminKey%"
echo;
pause



echo Set the metadata block for Root
curl -s -X POST -H "%MIME_TYPE_JSON%" -d "[\"citation\"]" %SERVER%dataverses/:root/metadatablocks/?key=%adminKey%
echo;
pause


echo Set the default facets for Root
curl -s -X POST -H "%MIME_TYPE_JSON%" -d "[\"authorName\",\"subject\",\"keywordValue\",\"dateOfDeposit\"]" %SERVER%dataverses/:root/facets/?key=%adminKey%
echo;
pause

:: echo Setting up a sample Shibboleth institutional group
:: curl -s -X POST -H "%MIME_TYPE_JSON%" --upload-file data/shibGroupTestShib.json "%SERVER%groups/shib?key=%adminKey%" 
:: echo 
:: pause

echo leaving the api directory
popd

echo exiting cmd script[%0]
SET SETUP-ADMINKEY=Y
echo SETUP-ADMINKEY=[%SETUP-ADMINKEY%]
goto :eof

:onErrorExit
popd
echo command file[%0] failed
echo SETUP-ADMINKEY=[%SETUP-ADMINKEY%]


Exit /B 1