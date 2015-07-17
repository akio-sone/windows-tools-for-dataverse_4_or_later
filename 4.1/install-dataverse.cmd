@echo off

echo running cmd script[%0]
echo within directory=[%~dp0]
echo this script prepares the windows environment to run Dataverse
set INSTALL-DATAVERSE=


:: prerequisites
:: this script assumes that glassfish 4.1 is already installed and running
rem ----------------------------------------------------------------------------
rem stage 0: run as admin check
rem ----------------------------------------------------------------------------

rem fltmc >nul 2>&1 && (
rem  echo you have admin permissions
rem ) || (
rem  echo you do NOT admin permissions
rem  rem goto :onErrorExit
rem )



rem ----------------------------------------------------------------------------
rem stage 1: have env vars ready
rem ----------------------------------------------------------------------------




:: set up environment variables

echo checking the argument
if "%~1" == "" (
    echo error: The answer file must be specified
    echo usage: %0 answer-file
    goto :onErrorExit
) else (
    echo answerfile is given by[%1]
)

call .\setup-env-vars.cmd %1
if NOT "%SETUP-ENV-VARS%" == "Y" (
    echo command file[setup-env-vars] failed 
    goto :onErrorExit
)
rem ----------------------------------------------------------------------------
rem set up solr
rem ----------------------------------------------------------------------------
rem echo stop solr anyway if it is running 
rem call .\stop-solr.cmd
rem pause

rem echo set-up solr
rem call .\setup-solr.cmd
rem pause

rem echo starting solr
rem here use start rather than call to pop up the console of solr
rem start .\start-solr.cmd

rem pause

rem ----------------------------------------------------------------------------
rem stage 2: relevant section of the install scrip
rem ----------------------------------------------------------------------------

:: goto :eof


::  VALIDATION/VERIFICATION OF THE CONFIGURATION VALUES:
:: 1. VERIFY MAIL SERVER THEY CONFIGURED:

:: to be coded 
:: manually done before this script is executed




:: 2. CHECK IF THE WAR FILE IS AVAILABLE:

:: make sure war file has been built
:: this segment was moved to setup-env_variables.cmd


:: 2b. CHECK IF THE SQL TEMPLATE IS IN PLACE AND CREATE THE SQL FILE

echo section equivalent to the original's segments 2, 3, and 4

:: 3. CHECK POSTGRES AND JQ AVAILABILITY:
:: assuming they had been installed individually

:: 3c. IF PSQL WAS FOUND IN THE PATH, CHECK ITS VERSION:
:: ditto: but is this check necessary?

:: 4a. CHECK IF POSTGRES IS RUNNING:
:: ditto

:: [4b. missing]

:: 4c. CHECK IF THIS DB ALREADY EXISTS:

:: 4d. CHECK IF THIS USER ALREADY EXISTS:

:: 4e. CREATE DVN DB USER:

:: 4f. CREATE DVN DB:
echo setting up the database
echo db user=[%DB_USER%]

echo db name=[%DB_NAME%]
echo reference db data=[%SQL_REFERENCE_DATA%]

rem the command below must be run by non-administrator
:: psql -h localhost -U %DB_USER% -d %DB_NAME% -f %HOME%\   \setup-dataverse-db.sql

echo DB_SETUP_SQL_FILE_NAME=[%DB_SETUP_SQL_FILE_NAME%]

call .\setup-database.cmd  %DB_SETUP_SQL_FILE_NAME%
if NOT "%SETUP-DATABASE%" == "Y" (
    echo command file[setup-database] failed 
    goto :onErrorExit
)

::  5. CONFIGURE GLASSFISH

echo segment 5 pre-glassfish set-up
rem this call is one-time only
rem call .\deploy-gf-aux-files.cmd



:: start domain, if not running:


echo set up GlassFish
rem this call is one-time only
rem call .\config-glassfish.cmd


rem goto :eof


echo the remaining of segment 5 and 6 
call .\deploy-war-file.cmd
if NOT "%DEPLOY-WAR-FILE%" == "Y" (
    echo command file[deploy-war-file] failed 
    goto :onErrorExit
)


echo segment 7 add reference sql data
call .\setup-ref-tables.cmd

if NOT "%SETUP-REF-TABLES%" == "Y" (
    echo command file[setup-ref-tables] failed 
    goto :onErrorExit
)


rem include a line equivalent to sleep 180;
rem echo wait for 60 seconds for DB processing
rem timeout 60 /nobreak


rem ===========================================================================
rem setup-all.sh equivalent 
rem ===========================================================================
rem command -v 
rem linux: jq >/dev/null 2>&1 || { echo ''; exit 1;}
rem windows: jq >nul 2>&1 || echo   

:: echo "deleting all data from Solr"
:: orignal curl command: 
:: curl http://localhost:8983/solr/update/json?commit=true -H "Content-type: application/json" -X POST -d "{\"delete\": { \"query\":\"*:*\"}}"

echo reset solr index
call .\reset-solr.cmd

if NOT "%RESET-SOLR%" == "Y" (
    echo command file[reset-solr] failed 
    goto :onErrorExit
)

pause


:: Everything + the kitchen sink, in a single script
:: - Setup the metadata blocks and controlled vocabulary
:: - Setup the builtin roles
:: - Setup the authentication providers
:: - setup the settings (local sign-in)
:: - Create admin user and root dataverse
:: - (optional) Setup optional users and dataverses

:: ----------------------------------------------------------------------------
rem 1st sub-batch file
echo setup the metadata blocks
call .\setup-datasetfields.cmd

if NOT "%SETUP-DATASETFIELDS%" == "Y" (
    echo command file[setup-datasetfields] failed 
    goto :onErrorExit
)



:: ----------------------------------------------------------------------------
rem 2nd sub-batch file
echo Setup the builtin roles
call .\setup-builtin-roles.cmd

if NOT "%SETUP-BUILTIN-ROLES%" == "Y" (
    echo command file[setup-builtin-roles] failed 
    goto :onErrorExit
)




:: ----------------------------------------------------------------------------
rem 3d sub-batch file
echo Setup the authentication providers
call .\setup-identity-providers.cmd

if NOT "%SETUP-IDENTITY-PROVIDERS%" == "Y" (
    echo command file[setup-identity-providers] failed 
    goto :onErrorExit
)


:: ----------------------------------------------------------------------------

rem last setup file
echo Setup the admin-key and root-dataverse
call .\setup-adminkey.cmd

if NOT "%SETUP-ADMINKEY%" == "Y" (
    echo command file[setup-adminkey] failed 
    goto :onErrorExit
)






:: ----------------------------------------------------------------------------
:: OPTIONAL USERS AND DATAVERSES
rem  call.\setup-optional.cmd

echo exiting cmd script[%0]
set INSTALL-DATAVERSE=Y
echo INSTALL-DATAVERSE=[%INSTALL-DATAVERSE%]


goto :eof

:onErrorExit
echo command file[%0] failed

echo INSTALL-DATAVERSE=[%INSTALL-DATAVERSE%]

Exit /B 1
