resource "azurerm_monitor_diagnostic_setting" "fsdh_log_audit" {
  name                       = "fsdh-log"
  target_resource_id         = azurerm_linux_web_app.datahub_proj_app.id
  storage_account_id         = data.azurerm_storage_account.datahub_storageaccount.id

  enabled_log { category = "AppServiceHTTPLogs" }
  enabled_log { category = "AppServiceAuthenticationLogs" }
  enabled_log { category = "AppServiceAppLogs" }
  enabled_log { category = "AppServiceAuditLogs" }
  enabled_log { category = "AppServiceIPSecAuditLogs" }
  enabled_log { category = "AppServicePlatformLogs" }
  enabled_log { category = "AppServiceConsoleLogs" }
}
