data "azurerm_client_config" "current" {}

data "azurerm_subscription" "az_subscription" {
  subscription_id = var.az_subscription_id
}

locals {
  app_service_plan_name   = lower("${var.resource_prefix}-proj-${var.project_cd}-app-plan-${var.environment_name}")
  app_service_name_shiny  = lower("${var.resource_prefix}-proj-${var.project_cd}-shiny-${var.environment_name}")
  resource_group_location = "canadacentral"
  storage_key_secret      = "storage-key"
  storage_sas_secret      = "container-sas"
  storage_acct_mount      = "datahub"
  root_passwd_secret      = "root-passwd"
  project_tags            = merge(var.common_tags, { "project_cd" : var.project_cd, "env" : var.environment_name })
  dns_record_name         = lower("${var.project_cd}-app")
}
