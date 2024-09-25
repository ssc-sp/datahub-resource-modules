resource "azurerm_monitor_diagnostic_setting" "log_databricks" {
  count = var.log_workspace_id != "" ? 1 : 0

  name                       = "datahub-log-dbr"
  target_resource_id         = azurerm_databricks_workspace.datahub_databricks_workspace.id
  log_analytics_workspace_id = var.log_workspace_id

  enabled_log { category = "clusters" }
  enabled_log { category = "accounts" }
  enabled_log { category = "dbfs" }
  enabled_log { category = "jobs" }
  enabled_log { category = "iamRole" }
  enabled_log { category = "notebook" }
  enabled_log { category = "repos" }
  enabled_log { category = "secrets" }
  enabled_log { category = "workspace" }
  enabled_log { category = "gitCredentials" }
  enabled_log { category = "globalInitScripts" }
  enabled_log { category = "instancePools" }
  enabled_log { category = "sqlPermissions" }
  enabled_log { category = "unityCatalog" }
}
