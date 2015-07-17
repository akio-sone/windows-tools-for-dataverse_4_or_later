@echo off
rem This command file deals with the section 6 deployment of the war file

echo running cmd script[%0]
echo within directory=[%~dp0]
echo this script covers the section 6 of CONFIGURE GLASSFISH

SET DEPLOY-WAR-FILE=


rem circuit breaker
IF NOT DEFINED GLASSFISH_BIN_DIR (
    ECHO GLASSFISH_BIN_DIR is not defined
    GOTO :onErrorExit
)


:: 6. DEPLOY APPLICATION:
rem assuming GLASSFISH_BIN_DIR and DATAVERSE_WAR_FILENAME are defined here

:: 6b. TRY TO (AUTO-)DEPLOY:
:: windows case, autodeploy does not work well

echo deploying the war file to glassfish
 
echo dataverese war file full path[%WARFILE_LOCATION%]
echo moving to %GLASSFISH_BIN_DIR% directory -----------------------------------

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

echo leaving the glassfish bin directory =======================================
popd








echo make sure dataverse is not deployed on glassfish
call .\undeploy-war-file.cmd
if NOT "%UNDEPLOY-WAR-FILE%" == "Y" (
    echo command file[undeploy-war-file] failed 
    goto :onErrorExit
) else (
    echo command file[undeploy-war-file] successfully ended
)



echo moving to %GLASSFISH_BIN_DIR% directory -----------------------------------
pushd %GLASSFISH_BIN_DIR%



rem asadmin.bat deploy --contextroot /dvn C:\ahome\dvn\mygithub\dvn\DVN-root\DVN-web\target\DVN-web.war
echo dataverese war file is to be deployed -- please Wait for a minute or more
call .\asadmin.bat deploy %WARFILE_LOCATION%


rem deployment check
echo checking whether dataverse is running on glassfish



if not defined DATAVERSE_APP_NAME (
    set DATAVERSE_APP_NAME=%DATAVERSE_WAR_FILENAME:~0,-4%
)

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
    echo war-file deployment has been completed
) else (
    echo previous command file[deploy-war-file] seems failed 
    echo dataverse is not running on glassfish
    goto :onErrorExit
)


rem timeout 180 /nobreak


echo leaving the glassfish bin directory ======================================
popd

echo completing war file deployment
echo the end of the section 6 the deployment of the war file

echo exiting cmd script[%0]

SET DEPLOY-WAR-FILE=Y
echo DEPLOY-WAR-FILE=[%DEPLOY-WAR-FILE%]
goto :eof


:onErrorExit
echo command file[%0] failed
echo DEPLOY-WAR-FILE=[%DEPLOY-WAR-FILE%]
Exit /B 1



