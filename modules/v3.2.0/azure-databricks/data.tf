data "azurerm_client_config" "current" {}
data "azurerm_subscription" "az_subscription" { subscription_id = var.az_subscription_id }

locals {
  databricks_name         = lower("${var.resource_prefix}-dbk-${var.project_cd}-${var.environment_name}")
  databricks_rg_name      = lower("${var.resource_prefix}-dbk-${var.project_cd}-${var.environment_name}-rg")
  resource_group_location = "canadacentral"
  datahub_blob_container  = "datahub"
  project_tags            = merge(var.common_tags, { "project_cd" : var.project_cd, "env" : var.environment_name })
  abfss_uri               = "abfss://${local.datahub_blob_container}@${var.storage_acct_name}.dfs.core.windows.net"
  wasbs_uri               = "wasbs://${local.datahub_blob_container}@${var.storage_acct_name}.blob.core.windows.net"
}
