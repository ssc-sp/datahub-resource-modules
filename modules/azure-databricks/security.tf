resource "azurerm_key_vault_access_policy" "kv_databricks_policy" {
  key_vault_id = var.key_vault_id
  tenant_id    = var.az_tenant_id
  object_id    = var.azure_databricks_enterprise_oid

  key_permissions = ["Get", "UnwrapKey", "WrapKey"]
}


resource "azurerm_databricks_workspace_customer_managed_key" "datahub_databricks_proj_cmk" {
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
