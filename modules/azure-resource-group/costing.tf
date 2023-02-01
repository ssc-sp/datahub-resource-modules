
resource "azurerm_monitor_action_group" "datahub_proj_action_group_email" {
  name                = "${var.resource_prefix}-proj-actiongroup-${var.project_cd}-${var.environment_name}"
  resource_group_name = azurerm_resource_group.az_project_rg.name
  short_name          = "p0action"

  email_receiver {
    name          = "datahub_default_email"
    email_address = var.default_alert_email
  }

  tags = merge(
    var.common_tags
  )
}

resource "azurerm_consumption_budget_resource_group" "az_project_rg_budget" {
  count = var.monthly_budget > 0 ? 1 : 0

  name              = "${local.resource_group_name}-budget"
  resource_group_id = azurerm_resource_group.az_project_rg.id

  amount     = var.monthly_budget
  time_grain = "Monthly"

  time_period { start_date = "2023-04-01T00:00:00Z" }

  filter {
    dimension {
      name = "ResourceId"
      values = [
        azurerm_monitor_action_group.datahub_proj_action_group_email.id,
      ]
    }
  }

  notification {
    enabled        = true
    threshold      = 90.0
    operator       = "EqualTo"
    threshold_type = "Actual"

    contact_emails = concat([var.default_alert_email], var.project_alert_email_list)

    contact_groups = [
      azurerm_monitor_action_group.datahub_proj_action_group_email.id,
    ]

    contact_roles = [
      "Owner",
    ]
  }
}

