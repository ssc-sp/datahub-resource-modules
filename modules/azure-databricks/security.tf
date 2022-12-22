resource "azurerm_key_vault_access_policy" "kv_databricks_policy" {
  key_vault_id = var.key_vault_id
  tenant_id    = var.az_tenant_id
  object_id    = var.az_databricks_sp

  key_permissions = ["Get", "UnwrapKey", "WrapKey"]
}
