@echo off
rem drop and recreate database for dataverse
echo running cmd script[%0]
echo within directory=[%~dp0]
echo drop and create the postgresql database

SET SETUP-DATABASE=


echo answer file [%1]
if "%~1" == "" (
    echo error: sql file is not specified
    echo usage: [%0] sql-file-name
    goto :onErrorExit
)

:: psql -h localhost -U %DB_USER% -d %DB_NAME% -f %HOME%\..\setup-dataverse-db.sql

echo SETUP_SQL_FILE=[%SETUP_SQL_FILE%]
rem call psql -h %DB_HOST% -U postgres -d postgres -w  -f %SETUP_SQL_FILE%
call psql -h %DB_HOST% -U postgres -d postgres  -f %1

echo exiting cmd script[%0]

SET SETUP-DATABASE=Y
echo SETUP-DATABASE=[%SETUP-DATABASE%]
goto :eof

:onErrorExit
echo command file [%0] failed
echo SETUP-DATABASE=[%SETUP-DATABASE%]
Exit /B 1