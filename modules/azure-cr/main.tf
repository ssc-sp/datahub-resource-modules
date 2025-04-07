
resource "azurerm_container_registry" "datahub_proj_acr" {
  name                = local.acr_name
  resource_group_name = var.resource_group_name
  location            = local.resource_group_location
  admin_enabled       = true
  sku                 = "Basic"

  encryption {
    key_vault_key_id   = var.key_vault_cmk_id
    identity_client_id = azurerm_user_assigned_identity.datahub_proj_acr_uai.client_id
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.datahub_proj_acr_uai.id
    ]
  }
}

resource "azurerm_role_assignment" "acr_role_sp" {
  scope                = azurerm_container_registry.datahub_proj_acr.id
  principal_id         = var.sp_client_oid
  role_definition_name = "Contributor"
}

resource "azurerm_role_assignment" "acr_role_app_service" {
  scope                = azurerm_container_registry.datahub_proj_acr.id
  principal_id         = var.app_service_oid
  role_definition_name = "AcrPull"
}

