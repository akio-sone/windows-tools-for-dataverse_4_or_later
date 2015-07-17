@echo off

echo running cmd script[%0]
echo within directory[%~dp0]
echo configuring GlassFish

echo ================================================================
echo  sections handled by glassfish-setup shell script start here ===
echo ================================================================

SET CONFIG-GLASSFISH=

echo Glassfish directory=[%GLASSFISH_ROOT%]
echo Domain directory=[%DOMAIN_DIR%]
echo GlassFish bin directory=[%GLASSFISH_BIN_DIR%]
rem circuit breaker
IF NOT DEFINED GLASSFISH_BIN_DIR (
    ECHO run setup-env-vars.cmd first before you run this cmd file
    goto :onErrorExit
)




echo  Moving to the glassfish bin directory -----------------------------------

pushd %GLASSFISH_BIN_DIR%

echo take the domain up, if needed
set ASADMIN_BAT=%GLASSFISH_BIN_DIR%asadmin.bat

for /f "tokens=1, 2, 3 usebackq delims= "  %%i in (`%ASADMIN_BAT% list-domains 2^>^&1`) do (
    echo [1 %%i]
    echo [2 %%j]
    echo [3 %%k]
    if %%i==%GLASSFISH_DOMAIN% if %%j==running (
        echo  %GLASSFISH_DOMAIN% is running
        set glassfish_running=T
    ) else (
        echo %GLASSFISH_DOMAIN% is not running
        set glassfish_running=F
    )
   
)

echo glassfish is running[%glassfish_running%]
if %glassfish_running%==F (
    echo start the domain
    call .\asadmin.bat %ASADMIN_OPTS% start-domain %GLASSFISH_DOMAIN%
) else (
    echo glassfish domain %GLASSFISH_DOMAIN% is running
)

rem echo undeploy the dataverse, if deployed: 

rem the following command may not work on windows 
rem therefore it is safer to do undeployment manually before 
rem this script run
rem call .\asadmin.bat %ASADMIN_OPTS% undeploy %DATAVERSE_APP_NAME%
echo returned to the batch directory ==========================================
popd


call .\undeploy-war-file.cmd
if NOT "%UNDEPLOY-WAR-FILE%" == "Y" (
    echo command file[undeploy-war-file] failed 
    goto :onErrorExit
) else (
    echo command file[undeploy-war-file] successfully ended
)

echo  Moving to the glassfish bin directory -----------------------------------
pushd %GLASSFISH_BIN_DIR%



call .\asadmin.bat %ASADMIN_OPTS% delete-jvm-options -XX\:MaxPermSize=192m
call .\asadmin.bat %ASADMIN_OPTS% create-jvm-options -XX\:MaxPermSize=512m
call .\asadmin.bat %ASADMIN_OPTS% delete-jvm-options -XX\:PermSize=256m
call .\asadmin.bat %ASADMIN_OPTS% create-jvm-options -XX\:PermSize=256m
call .\asadmin.bat %ASADMIN_OPTS% delete-jvm-options -Xmx512m
call .\asadmin.bat %ASADMIN_OPTS% create-jvm-options -Xmx%MEM_HEAP_SIZE%



::::::
:: JDBC connection pool

:: we'll try to delete a pool with this name, if already exists
:: - in case the database name has changed since the last time it was configured

call .\asadmin.bat %ASADMIN_OPTS% delete-jdbc-connection-pool ^
    --cascade=true dvnDbPool

call .\asadmin.bat %ASADMIN_OPTS% create-jdbc-connection-pool ^
    --restype javax.sql.DataSource ^
    --datasourceclassname org.postgresql.ds.PGPoolingDataSource ^
    --property create=true:User=%DB_USER%:PortNumber=%DB_PORT%:databaseName=%DB_NAME%:password=%DB_PASS%:ServerName=%DB_HOST% dvnDbPool


::::::
:: Create data sources
call .\asadmin.bat %ASADMIN_OPTS% create-jdbc-resource --connectionpoolid dvnDbPool jdbc/VDCNetDS

::::::
:: Set up the data source for the timers
call .\asadmin.bat %ASADMIN_OPTS% set configs.config.server-config.ejb-container.ejb-timer-service.timer-datasource=jdbc/VDCNetDS



::::::
:: Add the necessary JVM options: 
:: 
:: location of the datafiles directory: 
:: (defaults to dataverse/files in the users home directory)
:: c:\xxx contains a colon and this must be espaced
call .\asadmin.bat %ASADMIN_OPTS% create-jvm-options "-Ddataverse.files.directory=%FILES_DIR%"
:: Rserve-related JVM options: 
call .\asadmin.bat %ASADMIN_OPTS% create-jvm-options "-Ddataverse.rserve.host=%RSERVE_HOST%"
call .\asadmin.bat %ASADMIN_OPTS% create-jvm-options "-Ddataverse.rserve.port=%RSERVE_PORT%"
call .\asadmin.bat %ASADMIN_OPTS% create-jvm-options "-Ddataverse.rserve.user=%RSERVE_USER%"
call .\asadmin.bat %ASADMIN_OPTS% create-jvm-options "-Ddataverse.rserve.password=%RSERVE_PASS%"
:: Data Deposit API options
call .\asadmin.bat %ASADMIN_OPTS% create-jvm-options "-Ddataverse.fqdn=%DATAVERSE_HOST%"
:: password reset token timeout in minutes
call .\asadmin.bat %ASADMIN_OPTS% create-jvm-options "-Ddataverse.auth.password-reset-timeout-in-minutes=60"

call .\asadmin.bat %ASADMIN_OPTS% create-jvm-options "-Djavax.xml.parsers.SAXParserFactory=com.sun.org.apache.xerces.internal.jaxp.SAXParserFactoryImpl"

:: EZID DOI Settings
call .\asadmin.bat %ASADMIN_OPTS% create-jvm-options "-Ddoi.password=apitest"
call .\asadmin.bat %ASADMIN_OPTS% create-jvm-options "-Ddoi.username=apitest"
call .\asadmin.bat %ASADMIN_OPTS% create-jvm-options "-Ddoi.baseurlstring=https\://ezid.cdlib.org"

:: enable comet support
call .\asadmin.bat %ASADMIN_OPTS% set server-config.network-config.protocols.protocol.http-listener-1.http.comet-support-enabled="true"

call .\asadmin.bat %ASADMIN_OPTS% delete-connector-connection-pool --cascade=true jms/__defaultConnectionFactory-Connection-Pool 




:: no need to explicitly delete the connector resource for the connection pool deleted in the step 
:: above - the cascade delete takes care of it.

call .\asadmin.bat %ASADMIN_OPTS% create-connector-connection-pool --steadypoolsize 1 --maxpoolsize 250 --poolresize 2 --maxwait 60000 --raname jmsra --connectiondefinition javax.jms.QueueConnectionFactory jms/IngestQueueConnectionFactoryPool

call .\asadmin.bat %ASADMIN_OPTS% create-connector-resource --poolname jms/IngestQueueConnectionFactoryPool --description "ingest connector resource" jms/IngestQueueConnectionFactory

call .\asadmin.bat %ASADMIN_OPTS% create-admin-object --restype javax.jms.Queue --raname jmsra --description "sample administered object" --property Name=DataverseIngest jms/DataverseIngest

:: no need to explicitly create the resource reference for the connection factory created above 
:: the "create-connector-resource" creates the reference automatically.

:: created mail configuration

call .\asadmin.bat %ASADMIN_OPTS% create-javamail-resource --mailhost "%SMTP_SERVER%" --mailuser "dataversenotify" --fromaddress "do-not-reply@${DATAVERSE_HOST}" mail/notifyMailSession

:: so we can front with apache httpd
call .\asadmin.bat %ASADMIN_OPTS% create-network-listener --protocol http-listener-1 --listenerport 8009 --jkenabled true jk-connector

:::
:: Restart
echo Updates done. Restarting...
call .\asadmin.bat %ASADMIN_OPTS% restart-domain %GLASSFISH_DOMAIN%

:::
:: Clean up
echo leaving the glassfish bin directory ======================================
echo returned to the batch directory
popd

echo Glassfish setup complete
date /t
time /t
echo ================================================================
echo sections handled by glassfish-setup shell script ended here ====
echo=================================================================



echo end of cmd script[%0]
SET CONFIG-GLASSFISH=Y
echo flag CONFIG-GLASSFISH=[%CONFIG-GLASSFISH%]

goto :eof


:onErrorExit
echo cmd script[%0] failed due to some error
echo flag CONFIG-GLASSFISH=[%CONFIG-GLASSFISH%]
Exit /B 1

