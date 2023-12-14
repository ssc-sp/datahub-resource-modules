resource "azurerm_key_vault_access_policy" "kv_databricks_policy" {
  key_vault_id = var.key_vault_id
  tenant_id    = var.az_tenant_id
  object_id    = var.azure_databricks_enterprise_oid

  key_permissions    = ["Get", "UnwrapKey", "WrapKey"]
  secret_permissions = ["List", "Get"]
}

resource "databricks_secret_scope" "kv_secret_scope" {
  name = "datahub"

  keyvault_metadata {
    resource_id = var.key_vault_id
    dns_name    = var.key_vault_url
  }
}

resource "databricks_secret_acl" "kv_secret_scope_acl" {
  principal  = databricks_group.project_users.display_name
  permission = "READ"
  scope      = databricks_secret_scope.kv_secret_scope.name
}

resource "databricks_secret_acl" "kv_secret_scope_current_user" {
  principal  = data.azurerm_client_config.current.client_id
  permission = "READ"
  scope      = databricks_secret_scope.kv_secret_scope.name
}

resource "azurerm_databricks_workspace_root_dbfs_customer_managed_key" "datahub_databricks_proj_cmk" {
  workspace_id     = azurerm_databricks_workspace.datahub_databricks_workspace.id
  key_vault_key_id = var.key_vault_cmk_id

  depends_on = [azurerm_key_vault_access_policy.kv_policy_databricks_proj_cmk]
}

resource "azurerm_key_vault_access_policy" "kv_policy_databricks_proj_cmk" {
  key_vault_id = var.key_vault_id
  tenant_id    = azurerm_databricks_workspace.datahub_databricks_workspace.storage_account_identity.0.tenant_id
  object_id    = azurerm_databricks_workspace.datahub_databricks_workspace.storage_account_identity.0.principal_id

  key_permissions = [
    "Create",
    "Delete",
    "Get",
    "Purge",
    "Recover",
    "Update",
    "List",
    "Decrypt",
    "Sign",
    "WrapKey",
    "UnwrapKey"
  ]
}
