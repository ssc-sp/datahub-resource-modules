resource "azurerm_monitor_action_group" "datahub_proj_action_group_email" {
  name                = "${var.resource_prefix}-proj-actiongroup-${var.project_cd}-${var.environment_name}-email"
  resource_group_name = azurerm_resource_group.az_project_rg.name
  short_name          = "p0action"

  email_receiver {
    name          = "datahub_default_email"
    email_address = var.default_alert_email
  }

  tags = local.project_tags
}

resource "azurerm_monitor_action_group" "datahub_proj_action_group_cost" {
  name                = "${var.resource_prefix}-proj-actiongroup-${var.project_cd}-${var.environment_name}-cost"
  resource_group_name = azurerm_resource_group.az_project_rg.name
  short_name          = "p1action"

  automation_runbook_receiver {
    name                    = "rg_cost_limit"
    automation_account_id   = azurerm_automation_account.az_project_automation_acct.id
    runbook_name            = local.cost_runbook_name
    webhook_resource_id     = azurerm_automation_runbook.az_project_cost_stop_runbook.id
    is_global_runbook       = false
    service_uri             = azurerm_automation_webhook.az_project_cost_runbook_webhook.uri
    use_common_alert_schema = true
  }

  tags = local.project_tags
}

resource "azurerm_consumption_budget_resource_group" "az_project_rg_budget" {
  count = var.budget_amount > 0 ? 1 : 0

  name              = "${local.resource_group_name}-budget"
  resource_group_id = azurerm_resource_group.az_project_rg.id
  amount            = var.budget_amount
  time_grain        = "Annually"
  time_period { start_date = var.budget_start_date }

  notification {
    enabled        = false
    threshold      = 100.0
    operator       = "EqualTo"
    threshold_type = "Actual"

    contact_roles  = ["Owner"]
  }

  lifecycle {
    ignore_changes = [time_period, time_grain]
  }
}

resource "azurerm_consumption_budget_resource_group" "az_project_rg_budget_dbr" {
  count = var.budget_amount > 0 ? 1 : 0

  name              = "${local.resource_group_name}-dbr"
  resource_group_id = "/subscriptions/bc4bcb08-d617-49f4-b6af-69d6f10c240b/resourceGroups/fsdh-dbk-sw5-sand-rg"
  amount            = var.budget_amount
  time_grain        = "Annually"
  time_period { start_date = var.budget_start_date }

  notification {
    enabled        = false
    threshold      = 100.0
    operator       = "EqualTo"
    threshold_type = "Actual"

    contact_emails = concat([var.default_alert_email], var.project_alert_email_list)
    contact_groups = [azurerm_monitor_action_group.datahub_proj_action_group_email.id]
    contact_roles  = ["Owner"]
  }

  lifecycle {
    ignore_changes = [time_period, time_grain]
  }
}

