resource "azurerm_user_assigned_identity" "datahub_batch_uami" {
  location            = local.resource_group_location
  name                = "${local.batch_acct_name}-uami"
  resource_group_name = var.resource_group_name

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_role_assignment" "datahub_batch_storage_role" {
  for_each = toset(["Storage Blob Data Contributor"])

  scope                = var.storage_acct_id
  role_definition_name = each.key
  principal_id         = azurerm_user_assigned_identity.datahub_batch_uami.principal_id
}
