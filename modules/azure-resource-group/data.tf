data "azurerm_client_config" "current" {}

data "azurerm_subscription" "az_subscription" {
  subscription_id = var.az_subscription_id
}

locals {
  resource_group_name     = lower("${var.resource_prefix}_proj_${var.project_cd}_${var.environment_name}_rg")
  resource_group_location = var.az_location
  kv_name                 = lower("${var.resource_prefix}-proj-${var.project_cd}-${var.environment_name}-kv")
  cmk_name                = "project-cmk"
}
