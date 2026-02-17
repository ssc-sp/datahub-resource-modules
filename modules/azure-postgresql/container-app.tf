resource "azurerm_container_app" "container_app_pgadmin" {
  name                         = "${var.project_cd}-${var.environment_name}-pgadmin-app"
  container_app_environment_id = var.container_app_env_id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [var.container_app_env_uai]
  }

  template {
    container {
      name    = "pgadmin"
      image   = "ghcr.io/ssc-sp/pgadmin4"
      cpu     = "1"
      memory  = "2Gi"
      command = ["/bin/bash"]
      args    = ["-c", local.agadmin_command]

      env {
        name  = "FSDH_DB_HOST"
        value = azurerm_postgresql_flexible_server.datahub_psql_server.fqdn
      }
      env {
        name  = "FSDH_DB_NAME"
        value = local.psql_db_name
      }
      env {
        name        = "FSDH_DB_USER"
        secret_name = lower(local.secret_name_psql_user)
      }
      env {
        name        = "FSDH_DB_PASSWORD"
        secret_name = lower(local.secret_name_psql_password)
      }
      env {
        name  = "PGADMIN_DEFAULT_EMAIL"
        value = "not-in-use@ssc-spc.gc.ca"
      }
      env {
        name  = "PGADMIN_DEFAULT_PASSWORD"
        value = "not-in-use"
      }
      env {
        name  = "PGADMIN_SERVER_JSON_FILE"
        value = "/tmp/servers.json"
      }
    }
  }

  secret {
    name                = lower(local.secret_name_psql_user)
    identity            = var.container_app_env_uai
    key_vault_secret_id = azurerm_key_vault_secret.datahub_psql_admin.id
  }

  secret {
    name                = lower(local.secret_name_psql_password)
    identity            = var.container_app_env_uai
    key_vault_secret_id = azurerm_key_vault_secret.datahub_psql_password.id
  }

  ingress {
    external_enabled = false
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

resource "azurerm_container_app" "container_app_proxy" {
  name                         = "${var.project_cd}-${var.environment_name}-proxy-app"
  container_app_environment_id = var.container_app_env_id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  template {
    container {
      name    = "nginx"
      image   = "lscr.io/linuxserver/nginx"
      cpu     = 0.25
      memory  = "0.5Gi"
      command = ["/bin/bash"]
      args    = ["-c", "/docker-entrypoint.sh"] #local.nginx_command]
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
    ignore_changes = [tags]
  }
}

