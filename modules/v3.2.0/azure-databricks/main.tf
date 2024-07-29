resource "azurerm_databricks_workspace" "datahub_databricks_workspace" {
  name                              = local.databricks_name
  resource_group_name               = var.resource_group_name
  managed_resource_group_name       = local.databricks_rg_name
  location                          = local.resource_group_location
  sku                               = "premium"
  customer_managed_key_enabled      = true
  infrastructure_encryption_enabled = true
  no_public_ip                      = false

  tags = local.project_tags
}

resource "databricks_workspace_conf" "datahub_databricks_workspace_conf" {
  custom_config = {
    "enableTokensConfig" : true
  }
}
