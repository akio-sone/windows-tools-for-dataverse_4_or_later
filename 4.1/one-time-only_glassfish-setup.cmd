@echo off
echo running cmd script[%0]
echo within directory=[%~dp0]
echo this script does one-time-only GlassFish-relation configurations
set ONE-TIME-ONLY_GLASSFISH-SETUP=

rem step 1 read the env variables
echo step 1 read env variables from the answer file
if "%~1" == "" (
    echo the answer file must be specified
    goto :onErrorExit
) else (
    echo step 0 answerfile is given by[%1]
)

:: set up environment variables
call .\setup-env-vars.cmd %1
if NOT "%SETUP-ENV-VARS%" == "Y" (
    echo command file[setup-env-vars] failed 
    goto :onErrorExit
) else (
    echo step 1 setup-env-vars.cmd successfully ended
)

echo step 2 copy GlassFish-related files
rem step 2 copy necessary files that can be installed before
rem        glassfish started, i.e., assuming glassfish zip file is opened
rem        and not running

rem jdbc driver and weld jar
call .\deploy-gf-aux-files.cmd
if NOT "%DEPLOY-GF-AUX-FILES%" == "Y" (
    echo command file[deploy-gf-aux-files] failed 
    goto :onErrorExit
) else (
    echo step 2 deploy-gf-aux-files.cmd successfully ended
)


echo step 3 login GlassFish very first time
rem step 3 login glassfish

call .\login-glassfish.cmd
if NOT "%LOGIN-GLASSFISH%" == "Y" (
    echo command file[login-glassfish] failed 
    goto :onErrorExit
) else (
    echo step 3 login-glassfish.cmd successfully ended
)





echo step 4 configure GlassFish
rem step 4 setup jvm options etc.

call .\config-glassfish.cmd
if NOT "%CONFIG-GLASSFISH%" == "Y" (
    echo command file[config-glassfish] failed 
    goto :onErrorExit
) else (
    echo step 4config-glassfish.cmd successfully ended
)


echo glassfish is now ready for dataverse

rem sub-sequent steps for each deploy-undeploy cycle
echo ========================================================
echo before installing and configuring Dataverse,
echo make sure that solr server is running by
echo start-solr.cmd
echo due to a logging-window issue, it is not included here
echo ========================================================

echo exiting cmd script[%0]
SET ONE-TIME-ONLY_GLASSFISH-SETUP=Y
echo ONE-TIME-ONLY_GLASSFISH-SETUP=[%ONE-TIME-ONLY_GLASSFISH-SETUP%]

goto :eof


:onErrorExit
echo command file [%0] failed
echo ONE-TIME-ONLY_GLASSFISH-SETUP=[%ONE-TIME-ONLY_GLASSFISH-SETUP%] 

Exit /B 1