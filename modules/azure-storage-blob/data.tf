data "azurerm_client_config" "current" {}

data "azurerm_subscription" "az_subscription" {
  subscription_id = var.az_subscription_id
}

data "azurerm_monitor_action_group" "datahub_proj_action_group_email" {
  resource_group_name = var.resource_group_name
  name                = "${var.resource_prefix}-proj-actiongroup-${var.project_cd}-${var.environment_name}"
}

locals {
  storage_account_name     = lower("${var.resource_prefix}proj${var.project_cd}${var.environment_name}")
  storage_key_secret       = "storage-key"
  resource_group_location  = var.az_location
  storage_size_limit_bytes = 1024 * 1024 * 1024 * 1024 * var.storage_size_limit_tb
}
