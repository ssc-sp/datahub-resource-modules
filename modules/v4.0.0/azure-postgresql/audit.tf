
resource "azurerm_monitor_diagnostic_setting" "fsdl_audit" {
  name                       = "fsdh-log"
  target_resource_id         = azurerm_postgresql_flexible_server.datahub_psql_server.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log { category_group = "allLogs" }
  enabled_log { category_group = "audit" }
}
