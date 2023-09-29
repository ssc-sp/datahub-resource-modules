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
}

resource "azurerm_key_vault_secret" "root_passwd_secret" {
  name         = local.root_passwd_secret
  value        = random_password.docker_root_password.result
  key_vault_id = var.key_vault_id
}
