resource "azurerm_resource_group" "az_project_rg" {
  name     = local.resource_group_name
  location = local.resource_group_location

  tags = local.project_tags

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
  purge_protection_enabled        = true
  enabled_for_template_deployment = true
  enable_rbac_authorization       = true

  sku_name = "standard"

  tags = local.project_tags

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [azurerm_resource_group.az_project_rg]
}

resource "azurerm_key_vault_key" "az_proj_cmk" {
  name         = local.cmk_name
  key_vault_id = azurerm_key_vault.az_proj_kv.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]

  depends_on = [azurerm_role_assignment.kv_runner_role_contrib]
}

resource "azurerm_role_assignment" "kv_runner_role_owner" {
  scope                = azurerm_key_vault.az_proj_kv.id
  role_definition_name = "Owner"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "kv_runner_role_contrib" {
  scope                = azurerm_key_vault.az_proj_kv.id
  role_definition_name = "Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "kv_runner_role_rg" {
  scope                = azurerm_key_vault.az_proj_kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "kv_admin_role_contrib" {
  scope                = azurerm_key_vault.az_proj_kv.id
  role_definition_name = "Contributor"
  principal_id         = var.aad_admin_group_oid
}

resource "azurerm_role_assignment" "kv_admin_role_rg" {
  scope                = azurerm_key_vault.az_proj_kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = var.aad_admin_group_oid
}

resource "azurerm_role_assignment" "kv_automation_role" {
  scope                = azurerm_key_vault.az_proj_kv.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_automation_account.az_project_automation_acct.identity[0].principal_id
}

resource "azurerm_role_assignment" "kv_datahub_app_role" {
  scope                = azurerm_key_vault.az_proj_kv.id
  role_definition_name = "Contributor"
  principal_id         = var.datahub_app_sp_oid
}

resource "null_resource" "set_default_resource_group" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    interpreter = ["pwsh", "-Command"]
    command     = "az configure --defaults group=${azurerm_resource_group.az_project_rg.name}"
    on_failure  = fail
  }
}
