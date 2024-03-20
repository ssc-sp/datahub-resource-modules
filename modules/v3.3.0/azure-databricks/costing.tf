resource "azurerm_consumption_budget_resource_group" "az_project_rg_budget_dbr" {
  count = var.budget_amount > 0 ? 1 : 0

  name              = "${local.databricks_rg_name}-budget"
  resource_group_id = azurerm_databricks_workspace.datahub_databricks_workspace.managed_resource_group_id
  amount            = var.budget_amount
  time_grain        = "Annually"
  time_period { start_date = var.budget_start_date == "" ? local.current_fiscal_year_start : var.budget_start_date }

  notification {
    enabled        = false
    threshold      = 100.0
    operator       = "EqualTo"
    threshold_type = "Actual"

    contact_roles = ["Owner"]
  }

  lifecycle {
    ignore_changes = [time_period, time_grain]
  }
}

