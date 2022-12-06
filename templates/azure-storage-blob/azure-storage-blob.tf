module "azure_storage_blob_module" {
  source              = "github.com/ssc-sp/datahub-resource-modules/modules/azure-storage-blob"

  resource_group_name = module.resource_group_module.az_project_rg_name
  key_vault_id        = module.resource_group_module.az_project_kv_id
  key_vault_cmk_name  = module.resource_group_module.az_project_cmk

  az_tenant_id        = var.az_tenant
  az_subscription_id  = var.az_subscription
  project_cd          = var.project_cd

  # optional variables
  environment_name    = var.environment_name
  az_location         = var.az_location
}

output "azure_storage_blob_container_url" {
  value = module.azure_storage_blob_module.azure_storage_blob_container_url
}

output "azure_storage_blob_status" {
  value = "Complete"
}