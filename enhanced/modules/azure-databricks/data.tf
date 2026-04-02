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
  name                 = var.dbr_subnet_private
  virtual_network_name = var.vnet_name
  resource_group_name  = var.vnet_rg
}

locals {
  databricks_name           = lower("${var.resource_prefix}-dbk-${var.project_cd}-${var.environment_name}")
  databricks_rg_name        = lower("${var.resource_prefix}-dbk-${var.project_cd}-${var.environment_name}-rg")
  resource_group_location   = "canadacentral"
  datahub_blob_container    = "datahub"
  abfss_uri                 = "abfss://${local.datahub_blob_container}@${var.storage_acct_name}.dfs.core.windows.net"
  wasbs_uri                 = "wasbs://${local.datahub_blob_container}@${var.storage_acct_name}.blob.core.windows.net"
  current_fiscal_year_start = contains(["1", "2", "3"], formatdate("M", timestamp())) ? "${formatdate("YYYY", timestamp()) - 1}-04-01T00:00:00Z" : "${formatdate("YYYY", timestamp())}-04-01T00:00:00Z"
  public_access             = true
}
