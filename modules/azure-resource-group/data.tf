data "azurerm_client_config" "current" {}

data "azurerm_subscription" "az_subscription" {
  subscription_id = var.az_subscription_id
}

locals {
  resource_group_name     = lower("${var.resource_prefix}_proj_${var.project_cd}_${var.environment_name}_rg")
  resource_group_location = var.az_location
  kv_name                 = lower("${var.resource_prefix}-proj-${var.project_cd}-${var.environment_name}-kv")
  automation_acct_name    = lower("${var.resource_prefix}-proj-${var.project_cd}-${var.environment_name}-auto")
  cost_runbook_name       = lower("${var.resource_prefix}-proj-${var.project_cd}-${var.environment_name}-cost-runbook")
  cmk_name                = "project-cmk"
  webhook_expiry_time     = "2025-12-31T00:00:00Z"
}

data "template_file" "az_project_cost_runbook_script" {
  template = file("${path.module}/rg-disable-cmk.ps1")
  vars = {
    key_vault_name = azurerm_key_vault.az_proj_kv.name
  }
}

