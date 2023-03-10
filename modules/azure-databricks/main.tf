resource "azurerm_databricks_workspace" "datahub_databricks_workspace" {
  name                                  = local.databricks_name
  resource_group_name                   = var.resource_group_name
  managed_resource_group_name           = local.databricks_rg_name
  location                              = local.resource_group_location
  sku                                   = "premium"
  customer_managed_key_enabled          = true
  infrastructure_encryption_enabled     = true

  tags = local.project_tags
}
