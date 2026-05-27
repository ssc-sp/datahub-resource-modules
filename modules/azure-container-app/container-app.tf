resource "azurerm_container_app" "proj_container_webapp" {
  name                         = "${var.project_cd}-${var.environment_name}-aca-app"
  container_app_environment_id = azurerm_container_app_environment.proj_container_webapp_env.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.proj_aca_uami.id]
  }

  template {
    container {
      name   = "nginx"
      image  = "nginx:alpine"
      cpu    = 0.25
      memory = "0.5Gi"
      volume_mounts {
        name     = local.sample_volume
        path     = "/etc/nginx/conf.d"
        sub_path = "sample/conf"
      }
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
      env {
        name  = "CLIENT_ID"
        value = azurerm_user_assigned_identity.proj_aca_uami.client_id
      }
      env {
        name  = "PRINCIPAL_ID"
        value = azurerm_user_assigned_identity.proj_aca_uami.principal_id
      }
      env {
        name  = "STORAGE_NAME"
        value = var.storage_acct_name
      }
    }
    volume {
      name         = local.sample_volume
      storage_name = local.datahub_app_fileshare
      storage_type = "AzureFile"
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
