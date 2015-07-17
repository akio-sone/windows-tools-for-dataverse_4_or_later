@echo off
rem This command file deals with the section 6 deployment of the war file

echo running cmd script[%0]
echo within directory=[%~dp0]
echo this script undeploys Dataverse from GlassFish sever

SET UNDEPLOY-WAR-FILE=


rem circuit breaker
IF NOT DEFINED GLASSFISH_BIN_DIR (
    ECHO GLASSFISH_BIN_DIR is not defined
    GOTO :onErrorExit
)


 
echo dataverese app name=[%DATAVERSE_APP_NAME%]
if not defined DATAVERSE_APP_NAME (
    set DATAVERSE_APP_NAME=%DATAVERSE_WAR_FILENAME:~0,-4%
)

echo moving to %GLASSFISH_BIN_DIR% directory ----------------------------------

pushd %GLASSFISH_BIN_DIR%








echo make sure glassfish is running 
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


rem list currently running applications

set dataverse_deployed=F

for /f "tokens=1, 2, 3 usebackq delims= "  %%i in (`%ASADMIN_BAT% list-applications 2^>^&1`) do (
    echo 1st token=[%%i]
    echo 2nd token=[%%j]
    echo 3rd token=[%%k]
     if %%i==%DATAVERSE_APP_NAME%  (
         echo  %DATAVERSE_APP_NAME% is deployed
         set dataverse_deployed=T
         goto :list-app-end
     ) else (
         if %%i==Nothing (
            echo nothin was found no app is deployed
            set dataverse_deployed=F
            goto :list-app-end
         ) else (
            echo %DATAVERSE_APP_NAME% is not found
            set dataverse_deployed=F
         )
     )
    
)

:list-app-end

echo dataverse_deployed=[%dataverse_deployed%]

if "%dataverse_deployed%" == "T" (
    echo dataverse is currently deployed to glassfish
    echo dataveres is to be undeployed
    rem asadmin.bat undeploy dataverse-4.0.2

    call .\asadmin.bat undeploy %DATAVERSE_APP_NAME%

    echo Waiting for the dataverse application to be undeployed
    
    rem stop glassfish and start glassfish 
    rem restart option seems not work for windows
    echo stop glassfish server
    call .\asadmin.bat stop-domain

    echo start glassfish server
    call .\asadmin.bat start-domain
    

) else (
    echo dataverse[%DATAVERSE_APP_NAME%] is not deployed on glassfish
    echo no further action is taken here
)



echo leaving the glassfish bin directory =======================================
popd

echo completing Dataverse undeployment
echo the end of the section 6 the undeployment of Dataverse

echo exiting cmd script[%0]

SET UNDEPLOY-WAR-FILE=Y
echo UNDEPLOY-WAR-FILE=[%UNDEPLOY-WAR-FILE%]
goto :eof


:onErrorExit
echo command file[%0] failed
echo UNDEPLOY-WAR-FILE=[%UNDEPLOY-WAR-FILE%]
Exit /B 1



