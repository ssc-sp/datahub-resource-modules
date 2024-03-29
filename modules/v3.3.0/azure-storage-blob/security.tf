resource "azurerm_role_assignment" "kv_storage_role" {
  for_each = toset(["Key Vault Secrets User", "Key Vault Crypto User"])

  scope                = var.key_vault_id
  role_definition_name = each.key
  principal_id         = azurerm_storage_account.datahub_storageaccount.identity.0.principal_id
}

resource "azurerm_storage_account_customer_managed_key" "datahub_storageaccount_key" {
  storage_account_id = azurerm_storage_account.datahub_storageaccount.id
  key_vault_id       = var.key_vault_id
  key_name           = var.key_vault_cmk_name

  depends_on = [azurerm_role_assignment.kv_storage_role]
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
  principal_id         = var.automation_acct_id
}


resource "azurerm_key_vault_secret" "storage_key_secret" {
  name         = local.storage_key_secret
  value        = azurerm_storage_account.datahub_storageaccount.primary_access_key
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "storage_sas_secret" {
  name         = local.storage_sas_secret
  value        = data.azurerm_storage_account_blob_container_sas.datahub_container_sas.sas
  key_vault_id = var.key_vault_id
  tags         = { "start" : data.azurerm_storage_account_blob_container_sas.datahub_container_sas.start, "expiry" : data.azurerm_storage_account_blob_container_sas.datahub_container_sas.expiry }
}

