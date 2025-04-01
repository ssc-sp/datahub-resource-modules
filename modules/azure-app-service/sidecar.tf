resource "azapi_update_resource" "datahub_proj_enable_sidecar" {
  count = length(var.container_list) > 1 ? 1 : 0

  resource_id = azurerm_linux_web_app.datahub_proj_app.id
  type        = "Microsoft.Web/sites@2024-04-01"
  body = {
    properties = {
      siteConfig = {
        linuxFxVersion = "SITECONTAINERS"
      }
    }
  }
  lifecycle {
    replace_triggered_by = [azurerm_linux_web_app.datahub_proj_app]
  }
}

resource "azapi_resource" "datahub_proj_container" {
  for_each = { for idx, item in var.container_list : idx => item }

  type      = "Microsoft.Web/sites/sitecontainers@2024-04-01"
  parent_id = azurerm_linux_web_app.datahub_proj_app.id
  name      = each.key > 0 ? "sidecar-${each.key}" : "main"

  body = { # https://learn.microsoft.com/en-us/rest/api/appservice/web-apps/create-or-update-site-container?view=rest-appservice-2024-04-01#request-body
    properties = {
      image          = each.value.image
      isMain         = each.key > 0 ? false : true
      authType       = length(var.container_registry_password) == 0 ? "Anonymous" : "UserCredentials"
      userName       = var.container_registry_username
      passwordSecret = var.container_registry_password
      targetPort     = each.value.port
      volumeMounts   = [{ containerMountPath = "/datahub-blob", volumeSubPath = "/datahub-blob", "readOnly" = true }, { containerMountPath = "/datahub-fs", volumeSubPath = "/datahub-fs", "readOnly" = false }]
    }
  }

  depends_on = [azapi_update_resource.datahub_proj_enable_sidecar]
}
