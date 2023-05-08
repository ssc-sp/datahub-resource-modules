resource "azurerm_databricks_access_connector" "dbk_main_access_connector" {
  name                = lower("${var.resource_prefix}-dbk-${var.project_cd}-${var.environment_name}-connector")
  resource_group_name = var.resource_group_name
  location            = local.resource_group_location

  identity {
    type         = "UserAssigned"
    identity_ids = [var.az_databricks_uai]
  }
}

resource "databricks_metastore" "dbk_main_metastore" {
  name = "primary"
  storage_root = format("abfss://%s@%s.dfs.core.windows.net/",
    azurerm_storage_container.unity_catalog.name,
  azurerm_storage_account.unity_catalog.name)
  owner         = "uc admins"
  force_destroy = false
}

resource "databricks_metastore_assignment" "dbk_main_metastore_assignment" {
  metastore_id = databricks_metastore.dbk_main_metastore.id
  workspace_id = azurerm_databricks_workspace.datahub_databricks_workspace.id
}

resource "databricks_metastore_data_access" "dbk_main_metastore_access" {
  metastore_id = databricks_metastore.dbk_main_metastore.id
  name         = "fsdh-main-metastore-access"
  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.dbk_main_access_connector.id
  }
  is_default = true
}

resource "databricks_storage_credential" "dbk_main_credential" {
  name = lower("${var.resource_prefix}-dbk-${var.project_cd}-${var.environment_name}-credential")
  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.dbk_main_access_connector.id
  }
  comment = "FSDH main storage credential for ${var.storage_acct_name}"
}

resource "databricks_grants" "dbk_main_credential_use" {
  storage_credential = databricks_storage_credential.dbk_main_credential.id

  grant {
    principal  = databricks_group.project_users.display_name
    privileges = ["CREATE_EXTERNAL_LOCATION"]
  }
}
