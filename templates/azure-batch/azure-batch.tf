module "azure_batch_module" {
  source     = "github.com/ssc-sp/datahub-resource-modules//modules/{{version}}/azure-batch{{branch}}"
  depends_on = [module.azure_storage_blob_module]

  resource_group_name = module.resource_group_module.az_project_rg_name
  key_vault_id        = module.resource_group_module.az_project_kv_id
  key_vault_cmk_id    = module.resource_group_module.az_project_cmk_id
  key_vault_url       = module.resource_group_module.az_project_kv_url
  key_vault_name      = module.resource_group_module.az_project_kv_name
  storage_acct_name   = module.azure_storage_blob_module.azure_storage_account_name
  storage_acct_id     = module.azure_storage_blob_module.azure_storage_account_id

  # standard variables
  environment_name   = var.environment_name
  az_tenant_id       = var.az_tenant_id
  az_subscription_id = var.az_subscription_id
  project_cd         = var.project_cd
  common_tags        = var.common_tags

  # module specific
  batch_default_vm_sku    = var.batch_default_vm_sku
  batch_vm_max            = var.batch_vm_max
  batch_starter_image_url = var.batch_starter_image_url
}

output "azure_batch_module_status" {
  value = "completed"
}

output "azure_batch_acct_id" {
  value = module.azure_batch_module.datahub_proj_batch_acct_id
}

output "azure_batch_pool_id" {
  value = module.azure_batch_module.datahub_proj_batch_pool_id
}
