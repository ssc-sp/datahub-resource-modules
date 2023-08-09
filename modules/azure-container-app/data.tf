data "azurerm_client_config" "current" {}

data "azurerm_subscription" "az_subscription" {
  subscription_id = var.az_subscription_id
}

locals {
  container_app_env_name   = lower("${var.resource_prefix}-proj-${var.project_cd}-capp-env-${var.environment_name}")
  container_app_name       = lower("${var.resource_prefix}-proj-${var.project_cd}-capp-${var.environment_name}")
  resource_group_location  = "canadacentral"
  project_tags             = merge(var.common_tags, { "project_cd" : var.project_cd, "env" : var.environment_name })
}
