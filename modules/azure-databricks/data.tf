data "azurerm_subscription" "az_subscription" {
  subscription_id = var.az_subscription_id
}

data "azurerm_storage_account" "datahub_storageaccount" {
  name                = var.storage_acct_name
  resource_group_name = var.resource_group_name
}

locals {
  databricks_name         = lower("${var.resource_prefix}-dbk-${var.project_cd}-${var.environment_name}")
  databricks_rg_name      = lower("${var.resource_prefix}-dbk-${var.project_cd}-${var.environment_name}-rg")
  resource_group_location = "canadacentral"
  datahub_blob_container  = "datahub"
}
