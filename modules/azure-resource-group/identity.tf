resource "azurerm_user_assigned_identity" "dbk_uai" {
  name                = local.databricks_uai_name
  resource_group_name = azurerm_resource_group.az_project_rg.name
  location            = local.resource_group_location
}