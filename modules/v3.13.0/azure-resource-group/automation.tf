resource "azurerm_automation_runbook" "az_project_cost_stop_runbook" {
  name                    = local.cost_runbook_name
  resource_group_name     = azurerm_resource_group.az_project_rg.name
  location                = local.resource_group_location
  automation_account_name = data.azurerm_automation_account.common_automation_acct.name
  log_verbose             = true
  log_progress            = true
  description             = "Cost limiting runbook for project ${var.project_cd}"
  runbook_type            = "PowerShell"

  content = data.template_file.az_project_disable_cmk_script.rendered
  tags    = local.project_tags
}

resource "azurerm_automation_runbook" "az_project_cost_check_runbook" {
  name                    = local.cost_check_runbook_name
  resource_group_name     = azurerm_resource_group.az_project_rg.name
  location                = local.resource_group_location
  automation_account_name = data.azurerm_automation_account.common_automation_acct.name
  log_verbose             = true
  log_progress            = true
  description             = "Cost checking runbook for project ${var.project_cd}"
  runbook_type            = "PowerShell"

  draft {
    parameters {
      key      = "trigger_percent"
      type     = "string"
      position = 0
    }
  }

  content = data.template_file.az_project_cost_check_script.rendered
  tags    = local.project_tags
}

resource "azurerm_automation_runbook" "az_project_sas_token_runbook" {
  name                    = local.sas_rotate_runbook_name
  resource_group_name     = azurerm_resource_group.az_project_rg.name
  location                = local.resource_group_location
  automation_account_name = data.azurerm_automation_account.common_automation_acct.name
  log_verbose             = true
  log_progress            = true
  description             = "Rotate SAS token in AKV (container-sas) ${var.project_cd}"
  runbook_type            = "PowerShell"

  content = data.template_file.az_project_rorate_sas_script.rendered
  tags    = local.project_tags
}

resource "azurerm_automation_webhook" "az_project_cost_runbook_webhook" {
  name                    = "${local.cost_runbook_name}-webhook"
  resource_group_name     = azurerm_resource_group.az_project_rg.name
  automation_account_name = data.azurerm_automation_account.common_automation_acct.name
  expiry_time             = local.webhook_expiry_time
  enabled                 = true
  runbook_name            = azurerm_automation_runbook.az_project_cost_stop_runbook.name
  parameters = {
    key_vault_name = azurerm_key_vault.az_proj_kv.name
  }
}

resource "azurerm_role_assignment" "automation_acct_assignment" {
  scope                = data.azurerm_subscription.az_subscription.id
  role_definition_name = "Billing Reader"
  principal_id         = data.azurerm_automation_account.common_automation_acct.identity[0].principal_id
}

resource "azurerm_automation_schedule" "daily_cost_check" {
  name                    = "schedule-${local.cost_check_runbook_name}"
  resource_group_name     = azurerm_resource_group.az_project_rg.name
  automation_account_name = data.azurerm_automation_account.common_automation_acct.name
  frequency               = "Day"
  interval                = 1
  timezone                = "America/Toronto"
  start_time              = formatdate("YYYY-MM-DD'T'07:00:00Z", timeadd(timestamp(), "24h"))
  description             = "DataHub Schedule to check RG spend daily"

  lifecycle {
    ignore_changes = [start_time]
  }
}

resource "azurerm_automation_job_schedule" "daily_rotate_sas_token_schedule" {
  resource_group_name     = azurerm_resource_group.az_project_rg.name
  automation_account_name = data.azurerm_automation_account.common_automation_acct.name
  schedule_name           = azurerm_automation_schedule.daily_cost_check.name
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
  automation_account_name = data.azurerm_automation_account.common_automation_acct.name
  schedule_name           = azurerm_automation_schedule.daily_cost_check.name
  runbook_name            = azurerm_automation_runbook.az_project_cost_check_runbook.name

  parameters = {
    trigger_percent = "100"
  }
}
