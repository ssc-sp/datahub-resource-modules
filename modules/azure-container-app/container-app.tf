resource "azurerm_container_app" "proj_container_webapp" {
  name                         = "${var.project_cd}-${var.environment_name}-aca-app"
  container_app_environment_id = azurerm_container_app_environment.proj_container_webapp_env.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  template {
    container {
      name   = "nginx"
      image  = "nginx:alpine"
      cpu    = 0.25
      memory = "0.5Gi"
    }
    container {
      name   = "webapp"
      image  = "mcr.microsoft.com/dotnet/samples:aspnetapp"
      cpu    = 0.25
      memory = "0.5Gi"
      env {
        name  = "PORT"
        value = "8080"
      }
    }
  }

  ingress {
    external_enabled = true
    target_port      = 80
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }


  tags = var.project_tags

  lifecycle {
    ignore_changes = [tags["created_date"]]
  }
}
