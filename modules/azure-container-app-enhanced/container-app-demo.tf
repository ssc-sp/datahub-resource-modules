resource "azurerm_container_app" "proj_demo_app" {
  name                         = "${var.project_cd}-${var.environment_name}-aca-demo"
  container_app_environment_id = var.aca_env_id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.proj_aca_uami.id]
  }

  template {
    container {
      name   = "nginx"
      image  = "ghcr.io/linuxserver/nginx"
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

    # container {
    #   name   = "db"
    #   image  = "postgres:15"
    #   cpu    = "2.0"
    #   memory = "4.0Gi"
    #   args   = []
    #   volume_mounts {
    #     name     = local.app_volume
    #     path     = "/var/lib/postgresql/data"
    #     sub_path = "db/data"

    #   }
    #   env {
    #     name  = "POSTGRES_USER"
    #     value = "fsdhadmin"
    #   }
    #   env {
    #     name  = "POSTGRES_DB"
    #     value = "fsdh"
    #   }
    #   env {
    #     name        = "POSTGRES_PASSWORD"
    #     secret_name = azurerm_key_vault_secret.aca_psql_password.name
    #   }
    #   env {
    #     name  = "TZ"
    #     value = "America/Toronto"
    #   }
    # }

    min_replicas                     = 0
    max_replicas                     = 1
    termination_grace_period_seconds = 120

    volume {
      name          = local.app_volume
      storage_name  = azurerm_container_app_environment_storage.datahub_app.name
      storage_type  = "AzureFile"
      mount_options = "rw,dir_mode=0700,file_mode=0600,uid=999,gid=999"
    }
  }

  secret {
    name                = azurerm_key_vault_secret.aca_psql_password.name
    identity            = azurerm_user_assigned_identity.proj_aca_uami.id
    key_vault_secret_id = azurerm_key_vault_secret.aca_psql_password.id
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
    ignore_changes = [tags]
  }
}
