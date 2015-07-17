How to set up Dataverse 4.0 or later on Windows (Draft)
========================================================


Quick Start Guide
-------------------
Before you start

1. Build Dataverse's war file
2. Install required packages such as Glassfish server, PostgreSQL, Apache Solr, and jq tool
3. Make sure PostgreSQL is running and ``psql.exe`` and ``jq.exe`` are on the ``PATH`` variable

Then

1. Download all CMD files whose directory name matches with the version of Dataverse of your interest in a local directory
2. Modify the default answer file for the installation CMD file according to your settings
3. Run the one-time setup script (``one-time-only_glassfish-setup.cmd``)  with your customized answer file
4. Start Apache Solr server
5. Run the installation CMD file (``install-dataverse.cmd``) with your customized answer file



Further Details
----------------------------------------------------------------------------------------------------------
The original PERL-based installer calls several auxiliary BASH scripts with the source tree as follows::
```
  dataverse/scripts/install -+-> glassfish-setup.sh
                           |
                           +->../api/setup-all.sh
                                            |
                                            |
                                            +--> setup-datasetfiels.sh
                                            +--> setup-builtin-roles.sh
                                            +--> setup-identity-providers.sh

```
Translating the above scripts line-by-line from BASH to Windows CMD is impossible because for a certain command such as ``tr`` no Windows counterpart exists.  Therefore, I decided to re-organize the above original scripts in to two groups:

1. for the one-time-only setup/configuration of GlassFish such as``one-time-only_glassfish-setup.cmd``
2. for the deployment of Dataverse's war file such as ``install-dataverse.cmd``


The prepared Windows CMD files are NOT intended to set up Dataverse for a production setting; rather they are intended for developers who build and test Dataverse on Windows.  Thus, unlike the original scripts that install Dataverse from the scratch, these CMD files assume the following settings:

1. GlassFish 4.1 is installed by its installer or just unzipped into a directory from its zip file.
2. Postgresql 9.x is installed and its psql.exe is on the PATH variable
3. jq tool is installed and jq.exe is on the PATH variable
4. Apache Solr server 4.6.0 is installed and running

To make command line arguments simpler and shorter, an answer file is used to read into configuration settings instead of command line arguments.  Therefore, before you run the above CMD files, you must open the default-dvn-answer-file by your favorite text-editor and modify values according to your settings.  There are about 30 key=value pairs in the default-dvn-answer-file as follows:


key|value(example)|note|
---|---|---|
DATAVERSE_HOST|localhost|Dataverse server name
GLASSFISH_ROOT|C:\ahome\batch\test-bed\glassfish-4.1\glassfish4\|GlassFish root (absolute) directory
SMTP_SERVER|smtp.gmail.com|SMP server name
DB_HOST|localhost|Postgresql server name
DB_PORT|5432|Postgresql port number
DB_NAME|dvnDb|Database name for Dataverse
DB_USER|dvnApp|Database User name
DB_PASS|xxxxxx|Database password
RSERVE_HOST|xxx.x.xx.xxx|RServe server name
RSERVE_PORT|6311|RServe server port number
RSERVE_USER|rserve|RServe server user name
RSERVE_PASS|zzzzz|RServe server user password
GLASSFISH_DOMAIN|domain1|GlassFish Domain name for Dataverse
ASADMIN_OPTS|[space]|asadmin.bat command option(space means 'no option')
MEM_HEAP_SIZE|2048m|GlassFish Memory heap size
FILES_DIR|R:\dataverse\files|DataFile storage directory
POSTGRES_DRIVER|postgresql-9.4-1201.jdbc41.jar|Postgresql JDBC jar
POSTGRES_DRIVER_DIR|C:\ahome\jars\db-drivers\|location (absolute) of the PostgreSQL JDBC jar
DATAVERSE_PORT|8080|Dataverse port number
DATAVERSE_SRC_ROOT|C:\ahome\vagrant-box\dataverse\|The location (absolute) of the Dataverse source-tree
SOLR_PORT|8983|Apache Solr server's port number
SOLR_JAR_DIR|C:\solr-4.6.0\example\|The location (absolute) Apache Solr server
DATAVERSE_WAR_FILENAME|dataverse-4.1.war|Dataverse war file name
WELD_OSGI_JAR|weld-osgi-bundle-2.2.14.Final-glassfish4.jar|weld-osgi-bundle jar file name
JHOVE_CONFIG_FILE|jhove.conf|Jhove configuration file name
SOLR_CONFIG_DIR|C:\solr-4.6.0\example\solr\collection1\conf\|The configuration directory of Apache Solr server
SOLR_CONFIG_SCHEMA|schema.xml|Apache Solr's schema.xml file name
DATAVERSE_SOLR_CONFIG_PATH|conf\solr\4.6.0\|The relative path to the Dataverse-customized schema.xml file
DB_SETUP_SQL_FILE_NAME|setup-dataverse-db.sql|The SQL file to drop the database and re-create it
SQL_REFERENCE_DATA|reference_data.sql|The SQL file that inserts Dataverse's reference data









Waning about the version of Apache Solr version
  * Dataverse 4.0 employs the version 4.6 of Apache Solr whose commandline system differs from version 4.10 or later.


CMD-file structure
-------------------
0. answer files
  * default-dvn-answer-file

1. ``one-time-only_glassfish-setup.cmd``
  * one-time-only_glassfish-setup.cmd  [answer-file]
  * setup-env-vars.cmd
  * deploy-gf-aux-files.cmd
  * login-glassfish.cmd
  * config-glassfish.cmd
     * undeploy-war-file.cmd

2.  ``install-dataverse.cmd``
  * install-dataverse.cmd
  * setup-env-vars.cmd
  * setup-database.cmd     setup-dataverse-db.sql
  * deploy-war-file.cmd
     * undeploy-war-file.cmd
  * setup-ref-tables.cmd
  * reset-solr.cmd
  * setup-datasetfields.cmd
  * setup-builtin-roles.cmd
  * setup-identity-providers.cmd
  * setup-adminkey.cmd

3. solr-related files (incomplete)
  * setup-solr.cmd
  * start-solr.cmd
  * stop-solr.cmd
