resource "azurerm_automation_account" "az_project_automation_acct" {
  name                = local.automation_acct_name
  resource_group_name = azurerm_resource_group.az_project_rg.name
  location            = local.resource_group_location
  sku_name            = "Basic"

  identity { type = "SystemAssigned" }
}

resource "azurerm_automation_runbook" "az_project_cost_runbook" {
  name                    = local.cost_runbook_name
  resource_group_name     = azurerm_resource_group.az_project_rg.name
  location                = local.resource_group_location
  automation_account_name = azurerm_automation_account.az_project_automation_acct.name
  log_verbose             = true
  log_progress            = true
  description             = "Cost limiting runbook for project ${var.project_cd}"
  runbook_type            = "PowerShell"

  draft {
    parameters {
      key      = "key_vault_name"
      type     = "string"
      position = 0
    }
  }

  content = data.template_file.az_project_cost_runbook_script.rendered
}

resource "azurerm_automation_webhook" "az_project_cost_runbook_webhook" {
  name                    = "${local.cost_runbook_name}-webhook"
  resource_group_name     = azurerm_resource_group.az_project_rg.name
  automation_account_name = azurerm_automation_account.az_project_automation_acct.name
  expiry_time             = local.webhook_expiry_time
  enabled                 = true
  runbook_name            = azurerm_automation_runbook.az_project_cost_runbook.name
  parameters = {
    key_vault_name = azurerm_key_vault.az_proj_kv.name
  }
}
