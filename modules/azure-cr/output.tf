output "acr_id" {
  value = azurerm_container_registry.datahub_proj_acr.id
}

output "acr_admin_username" {
  value = azurerm_container_registry.datahub_proj_acr.admin_username
}

output "acr_admin_password" {
  value = azurerm_container_registry.datahub_proj_acr.admin_password
}
