resource "azurerm_role_assignment" "storage_contributor_assignment" {
  for_each = { for user in var.storage_contributor_users : user.email => user }

  scope                = azurerm_storage_account.datahub_storageaccount.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = each.value.oid
}

