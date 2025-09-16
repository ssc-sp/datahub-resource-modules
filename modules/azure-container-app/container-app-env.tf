resource "azurerm_container_app_environment" "proj_container_webapp_env" {
  name                       = "${local.base_name}-container-webapp-env"
  location                   = var.az_location
  resource_group_name        = var.resource_group_name
  logs_destination           = "log-analytics"
  log_analytics_workspace_id = var.log_analytics_workspace_id

  identity { type = "SystemAssigned" }

  workload_profile {
    name                  = "Consumption"
    workload_profile_type = var.container_app_size
    maximum_count         = var.container_app_max_node
    minimum_count         = var.container_app_min_node
  }
}
