resource "random_password" "datahub_psql_password" {
  length           = 20
  min_lower        = 5
  min_upper        = 5
  min_numeric      = 5
  special          = true
  override_special = "_%@"
  lifecycle {
    ignore_changes = [min_lower, min_upper, min_numeric]
  }
}

resource "azurerm_user_assigned_identity" "datahub_psql_uami" {
  location            = var.az_location
  name                = "${local.psql_server_name}-uami"
  resource_group_name = var.resource_group_name

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_postgresql_flexible_server" "datahub_psql_server" {
  name                   = local.psql_server_name
  resource_group_name    = var.resource_group_name
  location               = var.az_location
  version                = "12"
  storage_mb             = 32768
  administrator_login    = local.psql_admin_user
  administrator_password = random_password.datahub_psql_password.result
  backup_retention_days  = 7
  sku_name               = var.psql_sku
  zone                   = 3
  tags                   = local.project_tags

  customer_managed_key {
    key_vault_key_id                  = var.key_vault_cmk_id
    primary_user_assigned_identity_id = azurerm_user_assigned_identity.datahub_psql_uami.id
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.datahub_psql_uami.id]
  }

  depends_on = [azurerm_role_assignment.kv_psql_role_secret, azurerm_role_assignment.kv_psql_role_crypto]
}
