resource "azurerm_user_assigned_identity" "datahub_proj_acr_uai" {
  resource_group_name = var.resource_group_name
  location            = local.resource_group_location

  name = "${local.acr_name}-uai"
}

resource "azurerm_key_vault_access_policy" "kv_policy_datahub_sp" {
  key_vault_id = var.key_vault_id
  tenant_id    = var.az_tenant_id
  object_id    = azurerm_user_assigned_identity.datahub_proj_acr_uai.principal_id

  key_permissions = ["Get", "UnwrapKey", "WrapKey"]
}

