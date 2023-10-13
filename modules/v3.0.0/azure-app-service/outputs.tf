output "datahub_proj_app_service_plan" {
  value = azurerm_service_plan.datahub_proj_app_service_plan.id
}

output "app_service_name" {
  value = azurerm_linux_web_app.datahub_proj_app.name
}

output "app_service_id" {
  value = azurerm_linux_web_app.datahub_proj_app.id
}

output "proj_app_domain" {
  value = var.use_easy_auth ? azurerm_app_service_custom_hostname_binding.datahub_app_custom_host[0].hostname : ""
}

output "proj_app_azure_domain" {
  value = azurerm_linux_web_app.datahub_proj_app.default_hostname
}

output "proj_app_outbound_ip" {
  value = azurerm_linux_web_app.datahub_proj_app.outbound_ip_address_list
}
