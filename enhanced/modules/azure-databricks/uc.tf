resource "azurerm_databricks_access_connector" "datahub_workspace_storage" {
  name                = format("%s-connector", local.databricks_name)
  resource_group_name = var.resource_group_name
  location            = local.resource_group_location

  identity {
    type = "SystemAssigned"
  }

  tags = var.project_tags
}

resource "databricks_catalog" "datahub_proj_catalog" {
  name         = format("%s-cat", local.databricks_name)
  storage_root = local.catalog_uri
}

resource "databricks_storage_credential" "datahub_workspace_storage" {
  name = format("%s-cred", local.databricks_name)
  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.datahub_workspace_storage.id
  }
  isolation_mode = "ISOLATION_MODE_ISOLATED"
  force_update   = true
  comment        = "Managed identity credential"
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

resource "databricks_external_location" "datahub_workspace_location" {
  name            = format("%s-datahub", local.databricks_name)
  url             = format("abfss://%s@%s.dfs.core.windows.net", local.datahub_blob_container, var.storage_acct_name)
  credential_name = databricks_storage_credential.datahub_workspace_storage.id
  comment         = "Managed by TF"
  isolation_mode  = "ISOLATION_MODE_ISOLATED"

  depends_on = [azurerm_role_assignment.datahub_storage_blob_contrib, azurerm_role_assignment.datahub_storage_acct_contrib, azurerm_role_assignment.datahub_storage_queue_contrib, azurerm_role_assignment.datahub_storage_eventgrid_contrib]
}

resource "databricks_external_location" "datahub_workspace_catalog" {
  name            = format("%s-catalog", local.databricks_name)
  url             = format("abfss://%s@%s.dfs.core.windows.net", local.datahub_catalog_container, var.storage_acct_name)
  credential_name = databricks_storage_credential.datahub_workspace_storage.id
  comment         = "Managed by TF"
  isolation_mode  = "ISOLATION_MODE_ISOLATED"

  depends_on = [azurerm_role_assignment.datahub_storage_blob_contrib, azurerm_role_assignment.datahub_storage_acct_contrib, azurerm_role_assignment.datahub_storage_queue_contrib, azurerm_role_assignment.datahub_storage_eventgrid_contrib]
}

resource "databricks_grants" "external_location_grants" {
  external_location = databricks_external_location.datahub_workspace_location.id
  grant {
    principal  = jsondecode(data.http.get_group_lead.response_body).Resources[0].displayName
    privileges = ["ALL_PRIVILEGES", "MANAGE", "EXTERNAL_USE_LOCATION"]
  }
  grant {
    principal  = jsondecode(data.http.get_group_user.response_body).Resources[0].displayName
    privileges = ["WRITE_FILES", "READ_FILES"]
  }
  grant {
    principal  = jsondecode(data.http.get_group_guest.response_body).Resources[0].displayName
    privileges = ["READ_FILES"]
  }
}
