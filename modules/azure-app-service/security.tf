resource "random_password" "docker_root_password" {
  length           = 20
  min_lower        = 5
  min_upper        = 5
  min_numeric      = 5
  special          = true
  override_special = "_%@"

  lifecycle {
    ignore_changes = [min_lower, min_upper, min_numeric]
  }

  depends_on = [azurerm_key_vault_access_policy.kv_app_service_policy]
}

resource "azurerm_key_vault_secret" "root_passwd_secret" {
  name         = local.root_passwd_secret
  value        = random_password.docker_root_password.result
  key_vault_id = var.key_vault_id

  depends_on = [azurerm_key_vault_access_policy.kv_app_service_policy]
}

resource "azurerm_role_assignment" "datahub_proj_app_contrib" {
  scope                = azurerm_linux_web_app.datahub_proj_app.id
  role_definition_name = "Contributor"
  principal_id         = var.sp_client_oid
}

resource "azurerm_role_assignment" "blob_log_app_role" {
  scope                = data.azurerm_storage_account.datahub_storageaccount.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_web_app.datahub_proj_app.identity.0.principal_id
}
