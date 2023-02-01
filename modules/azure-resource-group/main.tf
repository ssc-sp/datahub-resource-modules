resource "azurerm_resource_group" "az_project_rg" {
  name     = local.resource_group_name
  location = local.resource_group_location

  tags = merge(
    var.common_tags
  )

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_key_vault" "az_proj_kv" {
  name                            = local.kv_name
  location                        = azurerm_resource_group.az_project_rg.location
  resource_group_name             = azurerm_resource_group.az_project_rg.name
  enabled_for_disk_encryption     = true
  tenant_id                       = var.az_tenant_id
  soft_delete_retention_days      = 90
  purge_protection_enabled        = true
  enabled_for_template_deployment = true

  sku_name = "standard"

  tags = merge(
    var.common_tags,
    { "environment_name" : var.environment_name }
  )

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [azurerm_resource_group.az_project_rg]
}

resource "azurerm_key_vault_key" "az_proj_cmk" {
  name         = local.cmk_name
  key_vault_id = azurerm_key_vault.az_proj_kv.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]

  depends_on = [azurerm_key_vault_access_policy.current_runner_access_policy]
}

resource "azurerm_key_vault_access_policy" "current_runner_access_policy" {
  key_vault_id = azurerm_key_vault.az_proj_kv.id
  tenant_id    = var.az_tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions    = ["Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey"]
  secret_permissions = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
}

resource "azurerm_key_vault_access_policy" "kv_policy_datahub_sp" {
  key_vault_id = azurerm_key_vault.az_proj_kv.id
  tenant_id    = var.az_tenant_id
  object_id    = var.datahub_app_object_id

  secret_permissions = ["List", "Get"]
}
