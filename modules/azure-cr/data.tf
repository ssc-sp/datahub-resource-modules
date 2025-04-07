data "azurerm_client_config" "current" {}

data "azurerm_subscription" "az_subscription" {
  subscription_id = var.az_subscription_id
}

data "azurerm_storage_account" "datahub_storageaccount" {
  name                = var.storage_acct_name
  resource_group_name = var.resource_group_name
}

locals {
  acr_name        = lower("${var.resource_prefix}-proj-${var.project_cd}-acr-${var.environment_name}")
  resource_group_location = "canadacentral"
  storage_key_secret      = "storage-key"
  storage_sas_secret      = "container-sas"
}
