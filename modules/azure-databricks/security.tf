resource "azurerm_key_vault_access_policy" "kv_databricks_policy" {
  key_vault_id = var.key_vault_id
  tenant_id    = var.az_tenant_id
  object_id    = var.az_databricks_sp

  key_permissions = ["Get", "UnwrapKey", "WrapKey"]
}

# resource "null_resource" "proj_storage_acct_role" {
#   for_each = { for username in var.admin_users : username.email => username }

#   provisioner "local-exec" {
#     command     = <<-EOT
#       az role assignment create --role "Storage Blob Data Contributor" --assignee "${each.key}" --scope "${data.azurerm_storage_account.datahub_storageaccount.id}"
#     EOT

#     on_failure = continue
#   }  
# }
