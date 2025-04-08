data "azurerm_client_config" "current" {}

data "azurerm_subscription" "az_subscription" {
  subscription_id = var.az_subscription_id
}

locals {
  acr_name                = lower(replace(replace(lower("${var.resource_prefix}-proj-${var.project_cd}-acr-${var.environment_name}"), "_", ""), "-", ""))
  resource_group_location = "canadacentral"
}
