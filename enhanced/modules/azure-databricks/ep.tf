resource "azurerm_private_endpoint" "datahub_proj_databricks_api_ep" {
  name                = lower("${local.databricks_name}-api-ep")
  location            = local.resource_group_location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id_pep

  private_service_connection {
    name                           = lower("${local.databricks_name}-api-conn")
    private_connection_resource_id = azurerm_databricks_workspace.datahub_databricks_workspace.id
    is_manual_connection           = false
    subresource_names              = ["databricks_ui_api"]
  }
}
