resource "azurerm_user_assigned_identity" "datahub_proj_aca_env_uai" {
  resource_group_name = azurerm_resource_group.az_project_rg.name
  location            = local.resource_group_location
  name                = "${local.base_name}-aca-env-uai"
}

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

resource "azurerm_key_vault_access_policy" "kv_policy_databricks" {
  key_vault_id    = azurerm_key_vault.az_proj_kv.id
  tenant_id       = var.az_tenant_id
  object_id       = "70e896fc-6a44-4458-99df-f941c0df6cc8"
  key_permissions = ["Get", "UnwrapKey", "WrapKey"]
}

resource "azurerm_key_vault_access_policy" "kv_policy_clamav_job" {
  key_vault_id       = azurerm_key_vault.az_proj_kv.id
  tenant_id          = var.az_tenant_id
  object_id          = azurerm_user_assigned_identity.datahub_proj_clamav_job_uai.principal_id
  secret_permissions = ["Get", "List"]
}

resource "azurerm_key_vault_access_policy" "kv_policy_cost_job" {
  key_vault_id    = azurerm_key_vault.az_proj_kv.id
  tenant_id       = var.az_tenant_id
  object_id       = data.azurerm_user_assigned_identity.proj_auto_acct_uai.principal_id
  key_permissions = ["Get", "UnwrapKey", "WrapKey", "List", "Update"]
}

resource "azurerm_key_vault_access_policy" "kv_policy_aca_env" {
  key_vault_id       = azurerm_key_vault.az_proj_kv.id
  tenant_id          = var.az_tenant_id
  object_id          = azurerm_user_assigned_identity.datahub_proj_aca_env_uai.principal_id
  secret_permissions = ["Get", "List"]
  key_permissions    = ["Get", "UnwrapKey", "WrapKey", "List", "Update"]
}

resource "azurerm_role_assignment" "proj_storage_clamav_job_role" {
  for_each = toset(["Contributor", "Storage Blob Data Contributor", "Storage Table Data Contributor", "Storage Queue Data Contributor"])

  scope                = azurerm_storage_account.datahub_storageaccount.id
  role_definition_name = each.key
  principal_id         = azurerm_user_assigned_identity.datahub_proj_clamav_job_uai.principal_id
}
