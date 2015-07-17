--
-- setup-dataverse-db.sql
-- 
-- \connect postgres ;
REVOKE CONNECT ON DATABASE "dvnDb" FROM public;
SELECT pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE pg_stat_activity.datname = 'dvnDb'
AND pid <> pg_backend_pid();
DROP DATABASE IF EXISTS "dvnDb" ;

CREATE DATABASE "dvnDb" with  ENCODING='UTF8' owner="dvnApp" CONNECTION LIMIT=-1;

-- SELECT rolename FROM pg_roles;
