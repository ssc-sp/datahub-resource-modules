output "aca_app_name" {
  value = azurerm_container_app.proj_container_app.name
}

output "aca_latest_dns" {
  value = azurerm_container_app.proj_container_app.latest_revision_fqdn
}
