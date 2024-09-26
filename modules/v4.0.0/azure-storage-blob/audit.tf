resource "azurerm_monitor_diagnostic_setting" "fsdh_audit" {
  name                       = "fsdh-log"
  target_resource_id         = "${azurerm_storage_account.datahub_storageaccount.id}/blobServices/default"
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log { category_group = "allLogs" }
  enabled_log { category_group = "audit" }
}
