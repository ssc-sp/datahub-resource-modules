output "datahub_proj_app_service_plan" {
  value = azurerm_service_plan.datahub_proj_app_service_plan.id
}

output "app_service_name" {
  value = azurerm_linux_web_app.datahub_proj_shiny_app.name
}

output "app_service_id" {
  value = azurerm_linux_web_app.datahub_proj_shiny_app.id
}
