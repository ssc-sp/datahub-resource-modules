resource "azurerm_container_app_environment" "proj_container_app_env" {
  name                           = "${local.base_name}-container-app-env"
  location                       = local.resource_group_location
  resource_group_name            = azurerm_resource_group.az_project_rg.name
  logs_destination               = "log-analytics"
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  internal_load_balancer_enabled = true

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.datahub_proj_container_app_env_uai.id]
  }
}
