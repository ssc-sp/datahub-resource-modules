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
  purge_protection_enabled        = false
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
  name         = azurerm_key_vault.az_proj_kv.name
  key_vault_id = azurerm_key_vault.az_proj_kv.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
}
