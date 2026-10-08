output "az_project_rg_name" {
  value = azurerm_resource_group.az_project_rg.name
}

output "az_project_rg_id" {
  value = azurerm_resource_group.az_project_rg.id
}

output "az_project_kv_name" {
  value = azurerm_key_vault.az_proj_kv.name
}

output "az_project_kv_id" {
  value = azurerm_key_vault.az_proj_kv.id
}

output "az_project_kv_url" {
  value = azurerm_key_vault.az_proj_kv.vault_uri
}

output "az_project_cmk" {
  value      = azurerm_key_vault_key.az_proj_cmk.name
  depends_on = [azurerm_key_vault_access_policy.current_runner_access_policy]
}

output "az_project_cmk_id" {
  value = "${azurerm_key_vault_key.az_proj_cmk.versionless_id}/${azurerm_key_vault_key.az_proj_cmk.version}"
}

output "current_subscription_display_name" {
  value = data.azurerm_subscription.az_subscription.display_name
}

output "project_cd" {
  value = var.project_cd
}

output "resource_group_name" {
  value = azurerm_resource_group.az_project_rg.name
}

output "resource_group_id" {
  value = azurerm_resource_group.az_project_rg.id
}

output "automation_acct_principal_id" {
  value = data.azurerm_user_assigned_identity.proj_auto_acct_uai.principal_id
}

output "automation_acct_clientid" {
  value = data.azurerm_user_assigned_identity.proj_auto_acct_uai.client_id
}

output "project_tags" {
  value = local.project_tags
}

output "container_app_env_id" { value = azurerm_container_app_environment.proj_container_app_env.id }
output "clamav_docker_image" { value = var.blob_scan_image }
output "costing_docker_image" { value = var.proj_cost_image }
output "clamav_job_uai" { value = azurerm_user_assigned_identity.datahub_proj_clamav_job_uai.id }
output "aca_env_uai" { value = azurerm_user_assigned_identity.datahub_proj_aca_env_uai.principal_id }

output "storage_acct_name" {
  value      = azurerm_storage_account.datahub_storageaccount.name
  depends_on = [azurerm_role_assignment.proj_storage_creator_role]
}

output "storage_acct_id" {
  value      = azurerm_storage_account.datahub_storageaccount.id
  depends_on = [azurerm_role_assignment.proj_storage_creator_role]
}

output "datahub_blob_endpoint" {
  value = azurerm_storage_account.datahub_storageaccount.primary_blob_endpoint
}

output "datahub_blob_container" {
  value = azurerm_storage_container.datahub_default.name
}

output "azure_storage_account_name" {
  value = azurerm_storage_account.datahub_storageaccount.name
}

output "azure_storage_account_id" {
  value = azurerm_storage_account.datahub_storageaccount.id
}

output "azure_storage_account_key" {
  value     = azurerm_storage_account.datahub_storageaccount.primary_access_key
  sensitive = true
}

output "azure_storage_container_name" {
  value = azurerm_storage_container.datahub_default.name
}

output "azure_temp_fileshare_name" {
  value = azurerm_container_app_environment_storage.datahub_temp.name
}

output "aca_env_id" { value = azurerm_container_app_environment.proj_container_app_env.id }



