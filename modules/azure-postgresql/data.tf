data "azurerm_client_config" "current" {}

# My public IP: data.http.myip.response_body
data "http" "myip" {
  url = "https://checkip.amazonaws.com"
}

locals {
  resource_name_suffix      = length(var.resource_name_suffix) > 0 ? "-${var.resource_name_suffix}" : ""
  psql_server_name          = lower("${var.resource_prefix}-${var.project_cd}-psql-${var.environment_name}${local.resource_name_suffix}")
  psql_admin_user           = "fsdhadmin"
  psql_db_name              = "fsdh"
  psql_all_ext              = "ADDRESS_STANDARDIZER,ADDRESS_STANDARDIZER_DATA_US,AMCHECK,ANON,AZURE_AI,AZURE_STORAGE,BLOOM,BTREE_GIN,BTREE_GIST,CITEXT,CUBE,DBLINK,DICT_INT,DICT_XSYN,EARTHDISTANCE,FUZZYSTRMATCH,HLL,HSTORE,HYPOPG,INTAGG,INTARRAY,ISN,LO,LOGIN_HOOK,LTREE,ORACLE_FDW,ORAFCE,PAGEINSPECT,PG_BUFFERCACHE,PG_CRON,PG_FREESPACEMAP,PG_HINT_PLAN,PG_PARTMAN,PG_PREWARM,PG_REPACK,PG_SQUEEZE,PG_STAT_STATEMENTS,PG_TRGM,PG_VISIBILITY,PGAUDIT,PGCRYPTO,PGLOGICAL,PGROUTING,PGROWLOCKS,PGSTATTUPLE,PLPGSQL,PLV8,POSTGIS,POSTGIS_RASTER,POSTGIS_SFCGAL,POSTGIS_TIGER_GEOCODER,POSTGIS_TOPOLOGY,POSTGRES_FDW,POSTGRES_PROTOBUF,SEMVER,SESSION_VARIABLE,SSLINFO,TABLEFUNC,TDIGEST,TDS_FDW,TIMESCALEDB,TSM_SYSTEM_ROWS,TSM_SYSTEM_TIME,UNACCENT,UUID-OSSP,VECTOR"
  psql_ext                  = "POSTGIS,CUBE,CITEXT,BTREE_GIST,PG_TRGM,FUZZYSTRMATCH,VECTOR,AZURE_AI,PGCRYPTO,POSTGIS_TOPOLOGY"
  secret_name_psql_user     = "datahub-psql-admin"
  secret_name_psql_password = "datahub-psql-password"
  pgadmin_user              = "donotreply@ssc-spc.gc.ca"
  pgadmin_command           = <<-EOT
    echo "{\"Servers\":{\"1\":{\"Name\":\"${azurerm_postgresql_flexible_server.datahub_psql_server.fqdn}\",\"Group\":\"Servers\",\"Host\":\"${azurerm_postgresql_flexible_server.datahub_psql_server.fqdn}\",\"Port\":5432,\"Username\":\"postgres\",\"MaintenanceDB\":\"postgres\",\"SSLMode\":\"prefer\",\"Shared\":true,\"PassFile\":\"/fsdh/pgpass\"}}}" > /fsdh/servers.json &&
    echo "${azurerm_postgresql_flexible_server.datahub_psql_server.fqdn}:5432:*:${local.psql_admin_user}:$FSDH_DB_PASSWORD" >/fsdh/pgpass && 
    chmod 660 /fsdh/*
    /venv/bin/python3 /pgadmin4/setup.py load-servers /fsdh/servers.json --user ${local.pgadmin_user}
    /entrypoint.sh        
  EOT
}
