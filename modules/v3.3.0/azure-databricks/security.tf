resource "azurerm_role_assignment" "kv_databricks_role_secret" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.azure_databricks_enterprise_oid
}

resource "azurerm_role_assignment" "kv_databricks_role_crypto" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Crypto User"
  principal_id         = var.azure_databricks_enterprise_oid
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

resource "databricks_secret_acl" "kv_secret_scope_acl_leads" {
  principal  = databricks_group.project_lead.display_name
  permission = "READ"
  scope      = databricks_secret_scope.kv_secret_scope.name
}

resource "azurerm_databricks_workspace_customer_managed_key" "datahub_databricks_proj_cmk" {
  workspace_id     = azurerm_databricks_workspace.datahub_databricks_workspace.id
  key_vault_key_id = var.key_vault_cmk_id

  depends_on = [azurerm_role_assignment.kv_databricks_role_storage]
}

resource "azurerm_role_assignment" "kv_databricks_role_storage" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Crypto User"
  principal_id         = azurerm_databricks_workspace.datahub_databricks_workspace.storage_account_identity.0.principal_id
}
