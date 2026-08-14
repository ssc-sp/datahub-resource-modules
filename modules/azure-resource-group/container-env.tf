resource "azurerm_container_app_environment" "proj_container_app_env" {
  name                       = "${local.base_name}-aca-env"
  location                   = local.resource_group_location
  resource_group_name        = azurerm_resource_group.az_project_rg.name
  logs_destination           = "log-analytics"
  log_analytics_workspace_id = var.log_analytics_workspace_id
  public_network_access      = "Enabled"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.datahub_proj_aca_env_uai.id]
  }

  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
    maximum_count         = 8
    minimum_count         = 0
  }
}

resource "azurerm_monitor_diagnostic_setting" "proj_log_aca_env" {
  name               = "${local.base_name}-container-job-env-log"
  target_resource_id = azurerm_container_app_environment.proj_container_app_env.id
  storage_account_id = azurerm_storage_account.datahub_storageaccount.id

  enabled_log { category_group = "allLogs" }
  enabled_log { category_group = "audit" }
}