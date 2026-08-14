resource "azapi_update_resource" "fsdh_app_ip_restrictions" {
  type      = "Microsoft.Web/sites/config@2025-03-01"
  name      = "web"
  parent_id = azurerm_linux_web_app.datahub_proj_app.id

  body = {
    properties = {
      ipSecurityRestrictions = local.allow_source_ip_list
    }
  }
}
