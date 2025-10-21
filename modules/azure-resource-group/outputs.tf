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
  value = azurerm_key_vault_key.az_proj_cmk.id
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

output "container_app_env_id" { value = azurerm_container_app_environment.proj_container_job_env.id }
output "clamav_docker_image" { value = local.docker_image_clamav }
output "costing_docker_image" { value = local.docker_image_proj_cost }
output "sas_docker_image" { value = local.docker_image_proj_sas }
output "clamav_job_uai" { value = azurerm_user_assigned_identity.datahub_proj_clamav_job_uai.id }
output "aca_job_env_uai" { value = azurerm_user_assigned_identity.datahub_proj_container_job_env_uai.principal_id }

