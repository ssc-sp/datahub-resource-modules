resource "azurerm_container_app_environment" "proj_container_app_env" {
  name                = "${local.base_name}-container-app-env"
  location            = var.az_location
  resource_group_name = var.resource_group_name
  logs_destination    = "azure-monitor"

  identity { type = "SystemAssigned" }

  workload_profile {
    name                  = var.container_app_profile == "Consumption" ? var.container_app_profile : "fsdh-app"
    workload_profile_type = var.container_app_size
    maximum_count         = var.container_app_max_node
    minimum_count         = var.container_app_min_node
  }

  tags = var.project_tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_monitor_diagnostic_setting" "proj_log_aca_app" {
  name               = "${local.base_name}-container-app-env-log"
  target_resource_id = azurerm_container_app_environment.proj_container_app_env.id
  storage_account_id = var.storage_acct_id

  enabled_log { category_group = "allLogs" }
  enabled_log { category_group = "audit" }
}
