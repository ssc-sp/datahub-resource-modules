resource "azurerm_databricks_workspace" "datahub_databricks_workspace" {
  name                        = local.databricks_name
  resource_group_name         = var.resource_group_name
  managed_resource_group_name = local.databricks_rg_name
  location                    = local.resource_group_location
  sku                         = "premium"

  tags = merge(
    var.common_tags,
    {
      env = var.environment_name,
      displayName : local.databricks_name
    }
  )
}
