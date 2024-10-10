resource "azurerm_automation_account" "az_project_automation_acct" {
  name                = local.automation_acct_name
  resource_group_name = azurerm_resource_group.az_project_rg.name
  location            = local.resource_group_location
  sku_name            = "Basic"

  identity {
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.proj_auto_acct_uai.id]
  }
  tags = local.project_tags
}

resource "azurerm_automation_runbook" "az_project_cost_check_runbook" {
  name                    = local.cost_check_runbook_name
  resource_group_name     = azurerm_resource_group.az_project_rg.name
  location                = local.resource_group_location
  automation_account_name = azurerm_automation_account.az_project_automation_acct.name
  log_verbose             = true
  log_progress            = true
  description             = "Cost checking runbook for project ${var.project_cd}"
  runbook_type            = "PowerShell"

  parameters = {
    trigger_percent = "100"
    key_vault_name  = azurerm_key_vault.az_proj_kv.name
    budget_name     = azurerm_consumption_budget_resource_group.az_project_rg_budget.0.name
    dbr_rg_name     = local.databricks_rg_name
    subscription_id = var.az_subscription_id
  }

  content = data.template_file.az_project_cost_check_script.rendered
  tags    = local.project_tags
}

resource "azurerm_automation_runbook" "az_project_sas_token_runbook" {
  name                    = local.sas_rotate_runbook_name
  resource_group_name     = azurerm_resource_group.az_project_rg.name
  location                = local.resource_group_location
  automation_account_name = azurerm_automation_account.az_project_automation_acct.name
  log_verbose             = true
  log_progress            = true
  description             = "Rotate SAS token in AKV (container-sas) ${var.project_cd}"
  runbook_type            = "PowerShell"

  content = data.template_file.az_project_rorate_sas_script.rendered
  tags    = local.project_tags
}

resource "azurerm_automation_schedule" "daily_3am_schedule" {
  name                    = "daily-3am-schedule"
  resource_group_name     = azurerm_resource_group.az_project_rg.name
  automation_account_name = azurerm_automation_account.az_project_automation_acct.name
  frequency               = "Day"
  interval                = 1
  timezone                = "America/Toronto"
  start_time              = formatdate("YYYY-MM-DD'T'07:00:00Z", timeadd(timestamp(), "24h"))
  description             = "DataHub Schedule to check RG spend daily"

  lifecycle {
    ignore_changes = [start_time]
  }
}

resource "azurerm_automation_runbook" "az_project_cost_stop_runbook" {
  name                    = local.cost_runbook_name
  resource_group_name     = azurerm_resource_group.az_project_rg.name
  location                = local.resource_group_location
  automation_account_name = azurerm_automation_account.az_project_automation_acct.name
  log_verbose             = true
  log_progress            = true
  description             = "Cost limiting runbook for project ${var.project_cd}"
  runbook_type            = "PowerShell"

  content = data.template_file.az_project_disable_cmk_script.rendered
  tags    = local.project_tags
}

resource "azurerm_automation_webhook" "az_project_cost_runbook_webhook" {
  name                    = "${local.cost_runbook_name}-webhook"
  resource_group_name     = azurerm_resource_group.az_project_rg.name
  automation_account_name = azurerm_automation_account.az_project_automation_acct.name
  expiry_time             = local.webhook_expiry_time
  enabled                 = true
  runbook_name            = azurerm_automation_runbook.az_project_cost_stop_runbook.name
  parameters = {
    key_vault_name = azurerm_key_vault.az_proj_kv.name
  }
}

resource "azurerm_automation_job_schedule" "daily_rotate_sas_token_schedule" {
  resource_group_name     = azurerm_resource_group.az_project_rg.name
  automation_account_name = azurerm_automation_account.az_project_automation_acct.name
  schedule_name           = azurerm_automation_schedule.daily_3am_schedule.name
  runbook_name            = azurerm_automation_runbook.az_project_sas_token_runbook.name

  parameters = {
    key_vault_name      = azurerm_key_vault.az_proj_kv.name
    subscription_id     = var.az_subscription_id
    storage_acct_name   = local.storage_account_name
    resource_group_name = local.resource_group_name
    sas_secret_name     = "container-sas"
    container_name      = "datahub"
  }
}

resource "azurerm_automation_job_schedule" "daily_cost_check_job_schedule" {
  resource_group_name     = azurerm_resource_group.az_project_rg.name
  automation_account_name = azurerm_automation_account.az_project_automation_acct.name
  schedule_name           = azurerm_automation_schedule.daily_3am_schedule.name
  runbook_name            = azurerm_automation_runbook.az_project_cost_check_runbook.name

  parameters = {
    trigger_percent = "100"
  }
}
