@echo off
rem this part deals with the section 7 populating the database
rem and 

echo running cmd script[%0]
echo within directory=[%~dp0]
echo this command file deals with the section 7 populating the database

SET SETUP-REF-TABLES=

:: 7. POPULATE DATABASE:
echo populate database with reference data

:: 7a. POPULATE LOCALLY:
echo Populating the database local PostgresQL instance

:: Copy the SQL file to %tmp%, where user postgres will definitely
:: have read access to it:


SET WRK_DIR=%TMP%\POSGRESQL\
IF NOT EXIST %WRK_DIR% (
    echo %WRK_DIR% does not exist and create it
    MD %WRK_DIR%
)


:: Copy the SQL file to %TMP%, where user postgres will definitely have read access to it:

setlocal

copy %SQL_REFERENCE_TEMPLATE% %WRK_DIR%  /Y

IF not ERRORLEVEL 0 (
    echo error level is not zero
    echo copying reference data file failed?
)

endlocal

:: check the result of the above copy

IF NOT EXIST %WRK_DIR%%SQL_REFERENCE_DATA% (
    echo postgresql reference-data file [%SQL_REFERENCE_DATA%] does not exist in %WRK_DIR%
    goto :onErrorExit
) ELSE (
    echo postgresql reference-data file [%SQL_REFERENCE_DATA%] exists in %WRK_DIR%
)

:: moving to the working directory

pushd %WRK_DIR%


set PGPASSWORD=%DB_PASS%
echo pg[%PGPASSWORD%]
psql -h %DB_HOST% -U %DB_USER% -d %DB_NAME% -f %WRK_DIR%%SQL_REFERENCE_DATA%


echo leaving the temp directory[%WRK_DIR%]

popd

SET SETUP-REF-TABLES=Y
echo SETUP-REF-TABLES=[%SETUP-REF-TABLES%]
echo exiting cmd script[%0]

goto :eof

:onErrorExit
rem popd is necessary ?
echo command file[%0] failed
echo SETUP-REF-TABLES=[%SETUP-REF-TABLES%]

Exit /B 1


