data "azurerm_subscription" "az_subscription" {
  subscription_id = var.az_subscription_id
}

data "http" "sample_databricks_notebook_python" {
  url             = "https://raw.githubusercontent.com/fsdh-pfds/datahub-samples/refs/heads/main/sample-scripts/fsdh-sample-python.py"
  request_headers = { Accept = "application/json" }
}

data "http" "sample_databricks_notebook_r" {
  url             = "https://raw.githubusercontent.com/fsdh-pfds/datahub-samples/refs/heads/main/sample-scripts/fsdh-sample-r.r"
  request_headers = { Accept = "application/json" }
}

data "http" "sample_databricks_notebook_sql" {
  url             = "https://raw.githubusercontent.com/fsdh-pfds/datahub-samples/refs/heads/main/sample-scripts/fsdh-sample-sql.sql"
  request_headers = { Accept = "application/json" }
}
data "azurerm_virtual_network" "datahub_vnet" {
  name                = var.vnet_name
  resource_group_name = var.vnet_rg
}

data "azurerm_subnet" "datahub_subnet_dbrprv" {
  name                 = var.dbr_subnet_private
  virtual_network_name = var.vnet_name
  resource_group_name  = var.vnet_rg
}
data "azurerm_subnet" "datahub_subnet_dbrpub" {
  name                 = var.dbr_subnet_public
  virtual_network_name = var.vnet_name
  resource_group_name  = var.vnet_rg
}

data "azuread_group" "datahub_admin_group" {
  object_id = var.aad_admin_group_oid
}

locals {
  databricks_name           = lower("${var.resource_prefix}-dbk-${var.project_cd}-${var.environment_name}")
  databricks_rg_name        = lower("${var.resource_prefix}-dbk-${var.project_cd}-${var.environment_name}-rg")
  resource_group_location   = "canadacentral"
  datahub_blob_container    = "datahub"
  datahub_catalog_container = "datahub-catalog"
  abfss_uri                 = "abfss://${local.datahub_blob_container}@${var.storage_acct_name}.dfs.core.windows.net"
  catalog_uri               = "abfss://${local.datahub_catalog_container}@${var.storage_acct_name}.dfs.core.windows.net"
  wasbs_uri                 = "wasbs://${local.datahub_blob_container}@${var.storage_acct_name}.blob.core.windows.net"
  current_fiscal_year_start = contains(["1", "2", "3"], formatdate("M", timestamp())) ? "${formatdate("YYYY", timestamp()) - 1}-04-01T00:00:00Z" : "${formatdate("YYYY", timestamp())}-04-01T00:00:00Z"
  public_access             = true
  kv_uri                    = "https://${split("/", var.key_vault_cmk_id)[2]}"
  kv_key_name               = split("/", var.key_vault_cmk_id)[4]
  kv_key_version            = split("/", var.key_vault_cmk_id)[5]
  group_name_lead           = "${local.databricks_name}-lead"
  group_name_user           = "${local.databricks_name}-user"
  group_name_guest          = "${local.databricks_name}-guest"
  catalog_privilege_lead    = ["ALL_PRIVILEGES", "MANAGE", "USE_CATALOG", "SELECT", "USE_SCHEMA", "MODIFY", "CREATE_TABLE", "CREATE_SCHEMA", "CREATE_FUNCTION", "EXECUTE"]
  catalog_privilege_user    = ["ALL_PRIVILEGES", "USE_CATALOG", "SELECT", "USE_SCHEMA", "MODIFY", "CREATE_TABLE"]
  catalog_privilege_guest   = ["USE_CATALOG", "SELECT", "USE_SCHEMA"]
  schema_privilege_lead     = ["ALL_PRIVILEGES", "USE_SCHEMA", "MODIFY", "CREATE_TABLE"]
  schema_privilege_user     = ["USE_SCHEMA", "CREATE_TABLE"]
  schema_privilege_guest    = ["SELECT", "USE_SCHEMA"]
  location_privilege_lead   = ["ALL_PRIVILEGES", "MANAGE", "EXTERNAL_USE_LOCATION", "CREATE_EXTERNAL_TABLE"]
  location_privilege_user   = ["WRITE_FILES", "READ_FILES", "CREATE_EXTERNAL_TABLE"]
  location_privilege_guest  = ["READ_FILES"]
}
