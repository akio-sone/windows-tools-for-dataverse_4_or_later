@echo off

:: YOU (THE HUMAN USER) SHOULD NEVER RUN THIS SCRIPT DIRECTLY!
:: It should be run by higher-level installers. 
:: The following arguments should be passed to it 
:: as environmental variables: 
:: (no defaults for these values are provided here!)
::
:: glassfish configuration: 
:: GLASSFISH_ROOT
:: GLASSFISH_DOMAIN
:: ASADMIN_OPTS
:: MEM_HEAP_SIZE
::
:: database configuration: 
:: DB_PORT
:: DB_HOST
:: DB_NAME
:: DB_USER
:: DB_PASS
::
:: Rserve configuration: 
:: RSERVE_HOST
:: RSERVE_PORT
:: RSERVE_USER
:: RSERVE_PASS
::
:: other local configuration:
:: DATAVERSE_HOST
:: SMTP_SERVER
:: FILES_DIR

:: The script is going to fail and exit if any of the
:: parameters aren't supplied. It is the job of the 
:: parent script to set all these env. variables, 
:: providing default values, if none are supplied by 
:: the user, etc. 



rem ============================================================================
rem read the answer file
rem ============================================================================

echo running cmd script[%0]
echo within directory[%~dp0]
echo set up environment variables for the installation of Dataverse

rem clear the flag var
SET SETUP-ENV-VARS=

:: test whether a command-line argument is  specified
echo answer file [%1]
if "%~1" == "" (
    rem call :nofilecase
    echo an answer file is not specified
    echo prematurely exiting this batch file [%0]
    goto :onErrorExit
)
rem  else (
rem call :okcase %1 
rem )
rem echo something unthinkable happened here
rem echo exiting this batch file[%0]
rem goto:onErrorExit



:: no answer file case

rem :nofilecase


:: answer file %1 is specified

rem :okcase
echo answer file [%1] is specified

:: read the contents of the answer file
echo start to read the answer file given by %1



for /f "tokens=1,2 delims==" %%a in (%1) do (
    echo [%%a %%b]
rem     if %%a == GLASSFISH_DIRECTORY (
rem         set %%a=%%b
rem     )
rem     
rem     if %%a==GLASSFISH_DOMAIN (
rem         set %%a=%%b
rem     )
    
        set %%a=%%b
        echo [%%a]:[%%b]

)



:: calculate the machine-dependent max heap size

rem token 1: uintx
rem token 2: MaxHeapSize
rem token 3: :=
rem token 4: 2139095040
rem token 5: {product}

rem    uintx MaxHeapSize    := 2139095040      {product}


    for /f "tokens=4 usebackq"  %%i in (`java -XX:+PrintFlagsFinal -version 2^>^&1 ^| findstr  /i "maxheapsize"`) do (

        echo i [%%i]
        set "RAW_MHS=%%i"
        echo raw mhs0 %RAW_MHS%
        
    )

    echo raw mhs [%RAW_MHS%]
    set /A MAX_HEAP_SIZE=(%RAW_MHS:~0,-6%)*3/8
    echo case 2 MHS is %MAX_HEAP_SIZE% Mbytes
    set MEM_HEAP_SIZE=%MAX_HEAP_SIZE%m
    echo MEM HEAP SIZE[%MEM_HEAP_SIZE%]


rem setting constants    
set DATAVERSE_APP_NAME=%DATAVERSE_WAR_FILENAME:~0,-4%
echo DATAVERSE_APP_NAME=[%DATAVERSE_APP_NAME%]

:: checking env variable 
echo checking whether env variables are properly defined

rem database server host name
if not defined DB_HOST (
    echo You must specify database host name in the answer file 
    goto :onErrorExit
) else (
    echo database host[%DB_HOST%]
)

rem database server port number
if not defined DB_PORT (
    echo You must specify database port number in the answer file 
    goto :onErrorExit
) else (
    echo database port[%DB_PORT%]
)

rem database name
echo database name[%DB_NAME%]
if not defined DB_NAME (
    echo You must specify database name in the answer file 
    goto :onErrorExit
) else (
    echo database name[%DB_NAME%]
)

rem database user name
if not defined DB_USER (
    echo You must specify database user name in the answer file 
    goto :onErrorExit
) else (
    echo database user[%DB_USER%]
)

rem database password
if not defined DB_PASS (
    echo You must specify database password in the answer file 
    goto :onErrorExit
) else (
    echo database password[%DB_PASS%]
)

rem rserver host name
if not defined RSERVE_HOST (
    echo You must specify Rserve host name in the answer file 
    goto :onErrorExit
) else (
    echo rserve host[%RSERVE_HOST%]
)

rem rserver port number
if not defined RSERVE_PORT (
    echo You must specify Rserve port number in the answer file 
    goto :onErrorExit
) else (
    echo rserve port[%RSERVE_PORT%]
)

rem rserver user name
if not defined RSERVE_USER (
    echo You must specify Rserve user name in the answer file 
    goto :onErrorExit
) else (
    echo rserve user[%RSERVE_USER%]
)

rem rserver password
if not defined RSERVE_PASS (
    echo You must specify Rserve password in the answer file 
    goto :onErrorExit
) else (
    echo rserve password[%RSERVE_PASS%]
)

rem SMTP server name
if not defined SMTP_SERVER (
    echo You must specify smtp server name in the answer file 
    goto :onErrorExit
) else (
    echo smtp server[%SMTP_SERVER%]
)

rem dataverse host name
if not defined DATAVERSE_HOST (
    echo You must specify host address in the answer file 
    goto :onErrorExit
) else (
    echo dataverse host name[%DATAVERSE_HOST%]
)

rem datafile storage location
if not defined FILES_DIR (
    echo You must specify data-files directory in the answer file 
    goto :onErrorExit
) else (
    echo data-files directory[%FILES_DIR%]
)

rem GlassFish MEM_HEAP_SIZE
if not defined MEM_HEAP_SIZE (
    echo memory heap size for glassfish is not defined
    echo use the default value[2048m]
    MEM_HEAP_SIZE=2048m
) else (
    echo memory heap size[%MEM_HEAP_SIZE%]
)

rem GlassFish Domain name
if not defined GLASSFISH_DOMAIN (
    echo You must specify glassfish domain name in the answer file 
    echo use the default value[domain1
    GLASSFISH_DOMAIN=domain1
) else (
    echo glassfish domain[%GLASSFISH_DOMAIN%]
)



rem postgresql jdbc driver

if not defined POSTGRES_DRIVER (
    echo postgresql jdbc driver name is not defined
    goto :onErrorExit
) else (
    echo postgresql jdbc driver [%POSTGRES_DRIVER%] is defined
)

rem postgresql jdbc driver storage directory
if not defined POSTGRES_DRIVER_DIR (
    echo postgresql jdbc driver storage directory is not defined
    goto :onErrorExit
) else (
    echo postgresql jdbc driver storage directory [%POSTGRES_DRIVER_DIR%] is defined
)


if not EXIST %POSTGRES_DRIVER_DIR%%POSTGRES_DRIVER% (
    echo postgresql jdbc driver does not exist
    goto :onErrorExit
) else (
    echo postgresql jdbc driver [%POSTGRES_DRIVER_DIR%%POSTGRES_DRIVER%] exists
)



rem GlassFish root directory
if not defined GLASSFISH_ROOT (
    echo you must specify glassfish root directory in the answer file 
    goto :onErrorExit
) else (
    echo glassfish root[%GLASSFISH_ROOT%]
)

if not EXIST %GLASSFISH_ROOT% (
    echo specified glassfish root directory does not exist
    goto :onErrorExit
) else (
    echo specified glassfish root exists
)



rem GlassFish bin directory
SET GLASSFISH_BIN_DIR=%GLASSFISH_ROOT%bin\
echo glassfish bin directory[%GLASSFISH_BIN_DIR%]

IF NOT EXIST %GLASSFISH_BIN_DIR% (
    echo glassfish bin directory[%GLASSFISH_BIN_DIR%] does not exist
    goto :onErrorExit
) ELSE (
    Echo specified glassfish bin directory exists
)

rem GlassFish domain directory
echo setting DOMAIN_DIR
SET DOMAIN_DIR=%GLASSFISH_ROOT%glassfish\domains\%GLASSFISH_DOMAIN%\
echo DOMAIN_DIR=[%DOMAIN_DIR%]

IF NOT EXIST %DOMAIN_DIR% (
    echo glassfish domain  directory[%DOMAIN_DIR%] does not exist
    goto :onErrorExit
) ELSE (
    Echo specified glassfish domain directory exists
)




rem GlassFish lib directory
rem GLASSFISH_LIB_DIR
echo setting GLASSFISH_LIB_DIR
SET GLASSFISH_LIB_DIR=%GLASSFISH_ROOT%glassfish\lib\
echo GLASSFISH_LIB_DIR[%GLASSFISH_LIB_DIR%]



rem Dataverse-source root directory
rem SET DATAVERSE_SRC_ROOT=C:\ahome\iqss\dataverse\
if not defined DATAVERSE_SRC_ROOT (
    echo You must specify DATAVERSE_SRC_ROOT in the answer file 
    goto :onErrorExit
) else (
    echo DATAVERSE_SRC_ROOT[%DATAVERSE_SRC_ROOT%]
)


IF NOT EXIST %DATAVERSE_SRC_ROOT% (
    echo Dataverse-source root directory [%DATAVERSE_SRC_ROOT%] does not exist
    goto :onErrorExit
) ELSE (
    Echo specified dataverse-source root directory exists
)



rem DATAVERSE_DOWNLOADS_DIR
SET DATAVERSE_DOWNLOADS_DIR=%DATAVERSE_SRC_ROOT%downloads\
echo DATAVERSE_DOWNLOADS_DIR[%DATAVERSE_DOWNLOADS_DIR%]

IF NOT EXIST %DATAVERSE_DOWNLOADS_DIR% (
    echo Dataverse-source download directory [%DATAVERSE_DOWNLOADS_DIR%] does not exist
    goto :onErrorExit
) ELSE (
    Echo specified dataverse-source download directory exists
)



rem SOLR_PORT
if not defined SOLR_PORT (
    echo solor port number is not specfied in the answer file
    echo solr port is set to the factory default 8983
    SET SOLR_PORT=8983
) else (
    echo solr server port[%SOLR_PORT%]
)


rem SOLR_JAR_DIR=C:\solr-4.7.0\example\
rem solr jar directory
if not defined SOLR_JAR_DIR (
    echo you must sepcify SOLR_JAR_DIR in the answer file
    goto :onErrorExit
) else (
    echo solr jar directory[%SOLR_JAR_DIR%]
)

IF NOT EXIST %SOLR_JAR_DIR% (
    echo Solr jar directory [%SOLR_JAR_DIR%] does not exist
    goto :onErrorExit
) ELSE (
    Echo specified solr jar directory exists
)


rem DATAVERSE_WAR_FILENAME=dataverse-4.0.war
rem dataverse war file name
if not defined DATAVERSE_WAR_FILENAME (
    echo you must specify DATAVERSE_WAR_FILENAME in the answer file
    goto :onErrorExit
) else (
    echo dataverse war file name[%DATAVERSE_WAR_FILENAME%]
)

rem dataverse war file location
rem WARFILE_LOCATION
SET WARFILE_LOCATION=%DATAVERSE_SRC_ROOT%target\%DATAVERSE_WAR_FILENAME%
ECHO WARFILE_LOCATION[%WARFILE_LOCATION%]


IF NOT EXIST %WARFILE_LOCATION% (
    echo dataverse war file[%WARFILE_LOCATION%] was not located
    goto :onErrorExit
) else (
    echo dataverse war file exists
)




rem weld osgi jar
if not defined WELD_OSGI_JAR (
    echo weld osgi jar file name is not defined
    goto :onErrorExit
) else (
    echo weld osgi jar file name [%WELD_OSGI_JAR%] is defined
)

IF NOT EXIST %DATAVERSE_DOWNLOADS_DIR%%WELD_OSGI_JAR% (
    echo new weld osgi jar file[%DATAVERSE_DOWNLOADS_DIR%%WELD_OSGI_JAR%] was not located
    goto :onErrorExit
) else (
    echo new weld osgi jar file exists
)



rem JHOVE_CONFIG_FILE

if not defined JHOVE_CONFIG_FILE (
    echo jhove conifg file name is not defined
    goto :onErrorExit
) else (
    echo jhove config file name [%WELD_OSGI_JAR%] is defined
)

SET JHOVE_CONFIG_FILE_LOCATION=%DATAVERSE_SRC_ROOT%conf\jhove\%JHOVE_CONFIG_FILE%
echo JHOVE_CONFIG_FILE_LOCATION[JHOVE_CONFIG_FILE_LOCATION]


IF NOT EXIST %JHOVE_CONFIG_FILE_LOCATION% (
    echo jhove config file=[%JHOVE_CONFIG_FILE_LOCATION%] was not located
    goto :onErrorExit
) else (
    echo jhove config file exists
)

rem jhove config file destination

SET JHOVE_CONFIG_FILE_DEST=%GLASSFISH_ROOT%glassfish\domains\%GLASSFISH_DOMAIN%\config\%JHOVE_CONFIG_FILE%
echo JHOVE_CONFIG_FILE_DEST[%JHOVE_CONFIG_FILE_DEST%]



rem SOLR_CONFIG_DIR
if not defined SOLR_CONFIG_DIR (
    echo you must sepcify SOLR_CONFIG_DIR in the answer file
    goto :onErrorExit
) else (
    echo solr config directory=[%SOLR_CONFIG_DIR%] exists
)
echo SOLR_CONFIG_DIR[%SOLR_CONFIG_DIR%]

rem SOLR_CONFIG_SCHEMA
if not defined SOLR_CONFIG_SCHEMA (
    echo you must sepcify SOLR_CONFIG_SCHEMA in the answer file
    goto :onErrorExit
) else (
    echo  file[%SOLR_CONFIG_SCHEMA%] exists
)
echo SOLR_CONFIG_SCHEMA[%SOLR_CONFIG_SCHEMA%]


IF NOT EXIST  %SOLR_CONFIG_DIR%%SOLR_CONFIG_SCHEMA%  (
    echo schema file=[%SOLR_CONFIG_DIR%%SOLR_CONFIG_SCHEMA%] does not exist
    goto :onErrorExit
) ELSE (
    Echo schema file=[%SOLR_CONFIG_DIR%%SOLR_CONFIG_SCHEMA%] exists
)



rem DATAVERSE_SOLR_CONFIG_PATH

if not defined DATAVERSE_SOLR_CONFIG_PATH (
    echo you must sepcify DATAVERSE_SOLR_CONFIG_PATH in the answer file
    goto :onErrorExit
) else (
    echo relative-path-to-solr-schema-dir[%DATAVERSE_SOLR_CONFIG_PATH%]
)

SET DATAVERSE_SOLR_CONFIG_DIR=%DATAVERSE_SRC_ROOT%%DATAVERSE_SOLR_CONFIG_PATH%

echo DATAVERSE_SOLR_CONFIG_DIR=[%DATAVERSE_SOLR_CONFIG_DIR%]


IF NOT EXIST %DATAVERSE_SOLR_CONFIG_DIR%%SOLR_CONFIG_SCHEMA% (
    echo schema file [%DATAVERSE_SOLR_CONFIG_DIR%%SOLR_CONFIG_SCHEMA%] does not exist
    goto :onErrorExit
) ELSE (
    Echo schema file [%DATAVERSE_SOLR_CONFIG_DIR%%SOLR_CONFIG_SCHEMA%] exists
)



rem database-setup sql file
rem used in setup-database.cmd
if not defined DB_SETUP_SQL_FILE_NAME (
    echo you must sepcify DB_SETUP_SQL_FILE_NAME in the answer file
    goto :onErrorExit
) else (
    echo database-setup sql file name[%DB_SETUP_SQL_FILE_NAME%] exists
)

SET DB_SETUP_SQL_FILE=%~dp0%DB_SETUP_SQL_FILE_NAME%
echo DB_SETUP_SQL_FILE=[%DB_SETUP_SQL_FILE%]
IF NOT EXIST %DB_SETUP_SQL_FILE% (
    echo database-setup sql file [%DB_SETUP_SQL_FILE%] does not exist
    goto :onErrorExit
) ELSE (
    Echo database-setup sql file exists
)



rem reference data sql file
SET WRK_DIR=%TMP%\POSGRESQL\


rem used in setup-database.cmd
if not defined SQL_REFERENCE_DATA (
    echo you must sepcify SQL_REFERENCE_DATA in the answer file
    goto :onErrorExit
) else (
    echo reference data sql file[%SQL_REFERENCE_DATA%] exists
)


SET SQL_REFERENCE_TEMPLATE=%DATAVERSE_SRC_ROOT%scripts\database\%SQL_REFERENCE_DATA%
echo SQL_REFERENCE_TEMPLATE[%SQL_REFERENCE_TEMPLATE%]

IF NOT EXIST %SQL_REFERENCE_TEMPLATE% (
    echo postgresql reference-data file [%SQL_REFERENCE_TEMPLATE%] does not exist
    goto :onErrorExit
) ELSE (
    Echo postgresql reference-data file [%SQL_REFERENCE_TEMPLATE%] exists
)



echo end of cmd script[%0]
rem update the flag var
SET SETUP-ENV-VARS=Y
echo flag SETUP-ENV-VARS=[%SETUP-ENV-VARS%]
goto :eof

:onErrorExit
echo cmd script[%0] failed due to some error
echo flag SETUP-ENV-VARS=[%SETUP-ENV-VARS%]

Exit /B 1
