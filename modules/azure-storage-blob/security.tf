resource "azurerm_key_vault_access_policy" "kv_storage_policy" {
  key_vault_id = var.key_vault_id
  tenant_id    = var.az_tenant_id
  object_id    = azurerm_storage_account.datahub_storageaccount.identity.0.principal_id

  key_permissions    = ["Get", "List", "UnwrapKey", "WrapKey", "Encrypt", "Decrypt", "Sign", "Verify"]
  secret_permissions = ["List", "Get"]
}

resource "azurerm_storage_account_customer_managed_key" "datahub_storageaccount_key" {
  storage_account_id = azurerm_storage_account.datahub_storageaccount.id
  key_vault_id       = var.key_vault_id
  key_name           = var.key_vault_cmk_name

  depends_on = [azurerm_key_vault_access_policy.kv_storage_policy]
}

data "azurerm_storage_account_sas" "datahub_storageaccount_sas" {
  connection_string = azurerm_storage_account.datahub_storageaccount.primary_connection_string
  https_only        = true
  signed_version    = "2017-07-29"

  resource_types {
    service   = true
    container = false
    object    = false
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = "2020-03-31"
  expiry = "2023-03-31"

  permissions {
    read    = true
    write   = true
    delete  = false
    list    = false
    add     = true
    create  = true
    update  = false
    process = false
    filter  = false
    tag     = true
  }
}

resource "null_resource" "proj_storage_creator_role" {
  provisioner "local-exec" {
    interpreter = ["pwsh", "-Command"]
    command     = <<-EOT
      az role assignment create --role "Storage Blob Data Contributor" --assignee "${data.azurerm_client_config.current.object_id}" --scope "${azurerm_storage_account.datahub_storageaccount.id}"
    EOT

    on_failure = fail
  }
}

resource "azurerm_key_vault_secret" "storage_key_secret" {
  name         = local.storage_key_secret
  value        = azurerm_storage_account.datahub_storageaccount.primary_access_key
  key_vault_id = var.key_vault_id
}

