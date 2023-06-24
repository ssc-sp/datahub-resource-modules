resource "databricks_metastore_assignment" "dbk_main_metastore_assignment" {
  metastore_id = var.dbr_metastore_id
  workspace_id = azurerm_databricks_workspace.datahub_databricks_workspace.workspace_id
}

resource "azurerm_databricks_access_connector" "dbk_main_access_connector" {
  name                = lower("${var.resource_prefix}-dbk-${var.project_cd}-${var.environment_name}-connector")
  resource_group_name = var.resource_group_name
  location            = local.resource_group_location

  identity { type = "SystemAssigned" }
}

resource "azurerm_role_assignment" "storage_blob_contributor_assignment_uai" {
  scope                = data.azurerm_storage_account.datahub_storageaccount.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_databricks_access_connector.dbk_main_access_connector.identity[0].principal_id
}

resource "databricks_storage_credential" "dbk_main_credential" {
  name = lower("${var.resource_prefix}-dbk-${var.project_cd}-${var.environment_name}-credential")
  azure_managed_identity { access_connector_id = azurerm_databricks_access_connector.dbk_main_access_connector.id }
  comment = "FSDH main storage credential for ${var.storage_acct_name}"
}

resource "databricks_external_location" "dbk_main_storage_account" {
  name            = lower("${var.resource_prefix}-dbk-${var.project_cd}-${var.environment_name}-location")
  url             = format("abfss://%s@%s.dfs.core.windows.net/", local.datahub_blob_container, var.storage_acct_name)
  credential_name = databricks_storage_credential.dbk_main_credential.id
  skip_validation = true
  depends_on      = [databricks_metastore_assignment.dbk_main_metastore_assignment]
}

resource "databricks_grants" "dbk_main_storage_use" {
  for_each = { for username in concat(var.admin_users, var.project_lead_users, var.project_users) : username.email => username }

  external_location = databricks_external_location.dbk_main_storage_account.id
  grant {
    principal  = each.key
    privileges = ["READ_FILES", "WRITE_FILES"]
  }
}
