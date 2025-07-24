resource "azurerm_user_assigned_identity" "datahub_proj_acr_uai" {
  resource_group_name = azurerm_resource_group.az_project_rg.name
  location            = local.resource_group_location
  name                = "${local.acr_name}-uai"
}

resource "azurerm_user_assigned_identity" "datahub_proj_clamav_job_uai" {
  resource_group_name = azurerm_resource_group.az_project_rg.name
  location            = local.resource_group_location
  name                = "${local.base_name}-clamav-job-uai"
}

resource "azurerm_key_vault_access_policy" "kv_policy_acr" {
  key_vault_id    = azurerm_key_vault.az_proj_kv.id
  tenant_id       = var.az_tenant_id
  object_id       = azurerm_user_assigned_identity.datahub_proj_acr_uai.principal_id
  key_permissions = ["Get", "UnwrapKey", "WrapKey"]
}

resource "azurerm_role_assignment" "acr_role_clamav_job" {
  scope                = azurerm_container_registry.datahub_proj_acr.id
  principal_id         = azurerm_user_assigned_identity.datahub_proj_clamav_job_uai.principal_id
  role_definition_name = "AcrPull"
}

resource "azurerm_key_vault_access_policy" "kv_policy_clamav_job" {
  key_vault_id       = azurerm_key_vault.az_proj_kv.id
  tenant_id          = var.az_tenant_id
  object_id          = azurerm_user_assigned_identity.datahub_proj_clamav_job_uai.principal_id
  secret_permissions = ["Get", "List"]
}


