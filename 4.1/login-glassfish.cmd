@echo off
rem this script assume that all necessary files are already copied

echo running cmd script[%0]
echo within directory[%~dp0]
echo the first-time login GlassFish

SET LOGIN-GLASSFISH=

rem the following segment corresponds to line 861 start domain, if not running

echo Glassfish directory [%GLASSFISH_ROOT%]
echo Glassfish Domain directory [%DOMAIN_DIR%]

echo  Moving to the glassfish bin directory to check the state of glassfish


rem circuit breaker
IF NOT DEFINED GLASSFISH_ROOT (
    ECHO GLASSFISH_ROOT is not defined
    GOTO :onErrorExit
)


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
    echo not necessary to start the domain
)


:: create asadmin login, so that the user doesn't have to enter
:: the username and password for every asadmin command, if
:: access to :4848 is password-protected:

rem system glassfish_dir. /bin/asadmin login

call .\asadmin.bat login

:: NEW: configure glassfish using ASADMIN commands:

rem success = setup_glassfish();

:: CHECK EXIT STATUS, BARF IF SETUP SCRIPT FAILED:

rem    echo ERROR! Failed to configure Glassfish domain
rem    echo see the error messages above - if any
rem    echo Aborting
rem
echo leaving the glassfish bin directory
echo returned to the batch directory
popd

echo end of cmd script[%0]
SET LOGIN-GLASSFISH=Y
echo flag LOGIN-GLASSFISH=[%LOGIN-GLASSFISH%]
goto :eof


:onErrorExit
cmd script[%0] failed
echo flag LOGIN-GLASSFISH=[%LOGIN-GLASSFISH%]
Exit /B 1