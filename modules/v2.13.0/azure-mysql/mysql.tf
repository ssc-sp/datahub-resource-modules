resource "random_password" "datahub_mysql_password" {
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

resource "azurerm_user_assigned_identity" "datahub_mysql_uami" {
  location            = var.az_location
  name                = "${local.mysql_server_name}-uami"
  resource_group_name = var.resource_group_name
}

resource "azurerm_mysql_flexible_server" "datahub_mysql_server" {
  name                   = local.mysql_server_name
  resource_group_name    = var.resource_group_name
  location               = var.az_location
  administrator_login    = local.mysql_admin_user
  administrator_password = random_password.datahub_mysql_password.result
  backup_retention_days  = 7
  sku_name               = var.mysql_sku
  tags                   = local.project_tags

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.datahub_mysql_uami.id]
  }
}
