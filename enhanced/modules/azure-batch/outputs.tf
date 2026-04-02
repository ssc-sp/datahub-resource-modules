output "datahub_proj_batch_acct_name" {
  value = azurerm_batch_account.datahub_batch_acct.name
}

output "datahub_proj_batch_acct_id" {
  value = azurerm_batch_account.datahub_batch_acct.id
}

output "datahub_proj_batch_pool_name" {
  value = azurerm_batch_pool.datahub_batch_default_pool.name
}

output "datahub_proj_batch_pool_id" {
  value = azurerm_batch_pool.datahub_batch_default_pool.id
}
