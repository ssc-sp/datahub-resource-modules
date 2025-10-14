resource "azurerm_user_assigned_identity" "proj_aca_uami" {
  location            = var.az_location
  name                = "${var.project_cd}-${var.environment_name}-aca-app-uami"
  resource_group_name = var.resource_group_name
}

resource "azurerm_key_vault_access_policy" "proj_aca_uami_policy" {
  key_vault_id       = var.key_vault_id
  tenant_id          = var.az_tenant_id
  object_id          = azurerm_user_assigned_identity.proj_aca_uami.principal_id
  secret_permissions = ["Get"]
  key_permissions    = ["Get", "UnwrapKey", "WrapKey"]
}

resource "azurerm_key_vault_secret" "aca_psql_password" {
  name         = "aca-psql-password"
  value        = random_password.aca_psql_password.result
  key_vault_id = var.key_vault_id
}
