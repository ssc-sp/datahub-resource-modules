resource "azurerm_databricks_workspace" "datahub_databricks_workspace" {
  name                              = local.databricks_name
  resource_group_name               = var.resource_group_name
  managed_resource_group_name       = local.databricks_rg_name
  location                          = local.resource_group_location
  sku                               = "premium"
  customer_managed_key_enabled      = true
  infrastructure_encryption_enabled = true

  custom_parameters {
    no_public_ip = false
  }

  tags = var.project_tags

  lifecycle {
    ignore_changes = [tags["created_date"]]
  }
}

resource "databricks_workspace_conf" "datahub_databricks_workspace_conf" {
  custom_config = {
    "enableTokensConfig" : true
  }
}

resource "azurerm_role_assignment" "datahub_storage_blob_contrib" {
  scope                = var.storage_acct_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_databricks_access_connector.datahub_workspace_storage.identity[0].principal_id
}


resource "azurerm_role_assignment" "datahub_storage_acct_contrib" {
  scope                = var.storage_acct_id
  role_definition_name = "Contributor"
  principal_id         = azurerm_databricks_access_connector.datahub_workspace_storage.identity[0].principal_id
}

resource "azurerm_role_assignment" "datahub_storage_queue_contrib" {
  scope                = var.storage_acct_id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = azurerm_databricks_access_connector.datahub_workspace_storage.identity[0].principal_id
}

resource "azurerm_role_assignment" "datahub_storage_eventgrid_contrib" {
  scope                = var.storage_acct_id
  role_definition_name = "EventGrid EventSubscription Contributor"
  principal_id         = azurerm_databricks_access_connector.datahub_workspace_storage.identity[0].principal_id
}

