resource "azurerm_application_insights" "az_proj_appinsight" {
  name                = local.func_appinsight
  location            = azurerm_resource_group.az_project_rg.location
  resource_group_name = azurerm_resource_group.az_project_rg.name
  workspace_id        = var.log_analytics_workspace_id
  application_type    = "web"
  retention_in_days   = 30

  tags = local.project_tags
}
