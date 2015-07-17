@echo off
rem the following copies should be done before glassfish starts

echo running cmd script[%0]
echo within directory[%~dp0]
echo deploy aux files for GlassFish server

rem reset the flag var
SET DEPLOY-GF-AUX-FILES=

echo -------------------------------------------------------
echo step 1. Installing the Glassfish PostgresQL driver
echo -------------------------------------------------------

echo POSTGRES_DRIVER_DIR POSTGRES_DRIVER[%POSTGRES_DRIVER_DIR%%POSTGRES_DRIVER%]
rem check the driver in the source directory
if not EXIST %POSTGRES_DRIVER_DIR%%POSTGRES_DRIVER% (
    echo postgresql jdbc driver does not exist in its source directory
    goto :onErrorExit
) else (
    echo postgresql jdbc driver [%POSTGRES_DRIVER_DIR%%POSTGRES_DRIVER%] exists in the source directory
    
    
    :: destination directory check
    if not EXIST %GLASSFISH_LIB_DIR%%POSTGRES_DRIVER% (
        echo postgresql jdbc driver does not exist in its destination
        echo copying the driver to the lib directory
        copy /Y %POSTGRES_DRIVER_DIR%%POSTGRES_DRIVER%  %GLASSFISH_LIB_DIR%
        
        
        :: check the above copy
        if not EXIST %GLASSFISH_LIB_DIR%%POSTGRES_DRIVER% (
            echo postgresql jdbc driver was not copied to its destination
            goto :onErrorExit
        ) else (
            echo postgresql jdbc driver [%GLASSFISH_LIB_DIR%%POSTGRES_DRIVER%] exists
        )

        
    ) else (
        echo postgresql jdbc driver [%GLASSFISH_LIB_DIR%%POSTGRES_DRIVER%] already exists in the glassfish directory
    )
    
    
    
)


echo -------------------------------------------------------
echo step 2. replacing the original weld-osgi-bundle.jar
echo -------------------------------------------------------


:: TODO unless vagrant up is done once, the jar does not exist in 
:: the directory=> download it by this script?

:: replace weld-osgi-bundle.jar before starting glassfish

echo WELD_OSGI_JAR[%WELD_OSGI_JAR%]

:: move the old jar to the tmp

echo move the current weld jar
set WELD_OLD=%GLASSFISH_ROOT%glassfish\modules\weld-osgi-bundle.jar


if EXIST %WELD_OLD% (
    echo weld-osgi-bundle.jar still exists in modules directory
    echo move the jar to the temp directory
    
    move /Y %WELD_OLD% %TMP% 
    
    
) else (
    echo original weld-osgi-bundle.jar no longer exists in  %GLASSFISH_ROOT%glassfish\modules directory
)

echo check whether the jar was moved
if EXIST %WELD_OLD% (
    echo weld-osgi-bundle.jar still  exists in modules directory -- move failed
    goto :onErrorExit
) else (
    echo weld-osgi-bundle.jar was moved from %GLASSFISH_ROOT%glassfish\modules directory
)


:: copy the new one to its destination
echo copy the updated jar

copy  /Y %DATAVERSE_DOWNLOADS_DIR%%WELD_OSGI_JAR%  %GLASSFISH_ROOT%glassfish\modules\ 

echo confirming the above copy 
if not EXIST %GLASSFISH_ROOT%glassfish\modules\%WELD_OSGI_JAR% (
    echo weld patch jar does not exist in modules directory
    goto :onErrorExit
) else (
    echo %WELD_OSGI_JAR% exists in %GLASSFISH_ROOT%glassfish\modules directory
)





echo -------------------------------------------------------
echo step 3 copying jhove.conf
echo -------------------------------------------------------


:: ..\..\conf\jhove\jhove.conf

echo JHOVE_CONFIG_FILE[%JHOVE_CONFIG_FILE%]
echo JHOVE_CONFIG_FILE_LOCATION[%JHOVE_CONFIG_FILE_LOCATION%]

:: existence check

echo  JHOVE_CONFIG_FILE_DEST[%JHOVE_CONFIG_FILE_DEST%]


IF NOT EXIST %JHOVE_CONFIG_FILE_DEST% (
    echo jhove config file [%JHOVE_CONFIG_FILE_DEST%] was not found in the glassfish conf directory
) ELSE (
    Echo jhove config file [%JHOVE_CONFIG_FILE_DEST%] was found in the glassfish conf directory and to be overwritten
)

copy /Y %JHOVE_CONFIG_FILE_LOCATION% %GLASSFISH_ROOT%glassfish\domains\%GLASSFISH_DOMAIN%\config\ 


echo jhove conf full path[%JHOVE_CONFIG_FILE_DEST%]

IF NOT EXIST %JHOVE_CONFIG_FILE_DEST% (
    echo jhove config file [%JHOVE_CONFIG_FILE_DEST%] does not exist in the glassfish conf directory
    goto :onErrorExit
) ELSE (
    Echo jhove config file [%JHOVE_CONFIG_FILE_DEST%] exists in the glassfish conf directory
)


echo -------------------------------------------------------
echo step 4 copy the solr schema file
echo -------------------------------------------------------


echo set solr config directory

rem SET SOLR_CONFIG_DIR=C:\solr-4.7.0\example\solr\collection1\conf\
echo SOLR_CONFIG_DIR=[%SOLR_CONFIG_DIR%]

rem SET SOLR_CONFIG_SCHEMA=schema.xml
echo SOLR_CONFIG_SCHEMA=[%SOLR_CONFIG_SCHEMA%]

rem SET DATAVERSE_SOLR_CONFIG_DIR=C:\ahome\iqss\dataverse\conf\solr\4.6.0\
echo DATAVERSE_SOLR_CONFIG_DIR=[%DATAVERSE_SOLR_CONFIG_DIR%]





echo back up the current solar schema file
setlocal

    copy /Y %SOLR_CONFIG_DIR%%SOLR_CONFIG_SCHEMA% %SOLR_CONFIG_DIR%%SOLR_CONFIG_SCHEMA%.old 

IF not ERRORLEVEL 0 (
    echo error level is not zero
    echo backuping the solar schema file failed
)

endlocal


echo copy the customized schema file to its destination
setlocal

    copy /Y %DATAVERSE_SOLR_CONFIG_DIR%%SOLR_CONFIG_SCHEMA% %SOLR_CONFIG_DIR% 

IF not ERRORLEVEL 0 (
    echo error level is not zero
    echo copying the solar schema file failed
)

endlocal

echo confirming the above copy of the customized schema file
IF NOT EXIST %SOLR_CONFIG_DIR%%SOLR_CONFIG_SCHEMA% (
    echo customized schema file [%SOLR_CONFIG_DIR%%SOLR_CONFIG_SCHEMA%] does not exist in the config directory
    goto :onErrorExit
) ELSE (
    echo customized schema file [%SOLR_CONFIG_DIR%%SOLR_CONFIG_SCHEMA%] exists in the config directory
)



echo end of cmd script[%0]
SET DEPLOY-GF-AUX-FILES=Y
echo DEPLOY-GF-AUX-FILES=[%DEPLOY-GF-AUX-FILES%]
goto :eof


:onErrorExit
echo DEPLOY-GF-AUX-FILES=[%DEPLOY-GF-AUX-FILES%]
Exit /B 1