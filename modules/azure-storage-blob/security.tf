resource "azurerm_key_vault_access_policy" "kv_policy_storage" {
  key_vault_id = var.key_vault_id
  tenant_id    = var.az_tenant_id
  object_id    = azurerm_storage_account.datahub_storageaccount.identity.0.principal_id

  key_permissions    = ["Get", "List", "Encrypt", "Decrypt", "Sign", "WrapKey", "UnwrapKey"]
  secret_permissions = ["Get", "List"]
}

resource "azurerm_storage_account_customer_managed_key" "datahub_storageaccount_key" {
  storage_account_id = azurerm_storage_account.datahub_storageaccount.id
  key_vault_id       = var.key_vault_id
  key_name           = var.key_vault_cmk_name

  depends_on = [azurerm_key_vault_access_policy.kv_policy_storage]
}

data "azurerm_storage_account_blob_container_sas" "datahub_container_sas" {
  connection_string = azurerm_storage_account.datahub_storageaccount.primary_connection_string
  container_name    = azurerm_storage_container.datahub_default.name
  https_only        = true

  start  = formatdate("YYYY-MM-DD", timeadd(timestamp(), "-24h"))
  expiry = formatdate("YYYY-MM-DD", timeadd(timestamp(), "2184h"))

  permissions {
    read   = true
    write  = true
    delete = true
    list   = true
    add    = true
    create = true
  }
}

resource "azurerm_role_assignment" "proj_storage_creator_role" {
  for_each = toset(["Storage Blob Data Contributor"])

  scope                = azurerm_storage_account.datahub_storageaccount.id
  role_definition_name = each.key
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "proj_storage_automation_contrib" {
  for_each = toset(["Storage Blob Data Contributor", "Reader and Data Access"])

  scope                = azurerm_storage_account.datahub_storageaccount.id
  role_definition_name = each.key
  principal_id         = var.automation_acct_principal_id
}

resource "azurerm_key_vault_secret" "storage_key_secret" {
  name         = local.storage_key_secret
  value        = azurerm_storage_account.datahub_storageaccount.primary_access_key
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "storage_conn_secret" {
  name         = local.storage_conn_secret
  value        = azurerm_storage_account.datahub_storageaccount.primary_connection_string
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "storage_sas_secret" {
  name         = local.storage_sas_secret
  value        = data.azurerm_storage_account_blob_container_sas.datahub_container_sas.sas
  key_vault_id = var.key_vault_id
  tags         = { "start" : data.azurerm_storage_account_blob_container_sas.datahub_container_sas.start, "expiry" : data.azurerm_storage_account_blob_container_sas.datahub_container_sas.expiry }
}

resource "azurerm_security_center_storage_defender" "datahub_storageaccount_defender" {
  count = var.enable_defender ? 1 : 0

  storage_account_id                          = azurerm_storage_account.datahub_storageaccount.id
  override_subscription_settings_enabled      = true
  sensitive_data_discovery_enabled            = true
  malware_scanning_on_upload_enabled          = true
  malware_scanning_on_upload_cap_gb_per_month = -1
}

resource "azurerm_user_assigned_identity" "datahub_proj_sas_token_job_uai" {
  resource_group_name = var.resource_group_name
  location            = local.resource_group_location
  name                = "${local.base_name}-sas-job-uai"
}

resource "azurerm_role_assignment" "proj_storage_sas_job_role" {
  scope                = azurerm_storage_account.datahub_storageaccount.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.datahub_proj_sas_token_job_uai.principal_id
}

resource "azurerm_role_assignment" "acr_role_sas_job" {
  scope                = data.azurerm_container_registry.datahub_proj_acr.id
  principal_id         = azurerm_user_assigned_identity.datahub_proj_sas_token_job_uai.principal_id
  role_definition_name = "AcrPull"
}

resource "azurerm_key_vault_access_policy" "kv_policy_sas_job" {
  key_vault_id = var.key_vault_id
  tenant_id    = var.az_tenant_id
  object_id    = azurerm_user_assigned_identity.datahub_proj_sas_token_job_uai.principal_id

  secret_permissions = ["Get", "List", "Set"]
}