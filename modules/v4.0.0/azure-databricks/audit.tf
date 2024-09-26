resource "azurerm_monitor_diagnostic_setting" "fsdh_audit" {
  name                       = "fsdh-log"
  target_resource_id         = azurerm_databricks_workspace.datahub_databricks_workspace.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log { category_group = "allLogs" }
}
