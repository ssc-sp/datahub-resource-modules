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
    dynamic "container" {
      for_each = var.container_app_list

      content {
        name   = container.value.name
        image  = container.value.image
        cpu    = container.value.cpu
        memory = container.value.memory

        dynamic "volume_mounts" {
          for_each = container.value.volumes

          content {
            name     = volume_mounts.value.name
            path     = volume_mounts.value.path
            sub_path = volume_mounts.value.sub_path
          }
        }

        dynamic "env" {
          for_each = var.container_app_secrets

          content {
            name        = replace(env.value.name, "-", "_")
            secret_name = lower(env.value.name)
          }
        }

        dynamic "env" {
          for_each = container.value.env

          content {
            name  = replace(env.value.name, "-", "_")
            value = env.value.value
          }
        }

        env {
          name        = "AZURE_STORAGE_ACCESS_KEY"
          secret_name = local.secret_name_storage_key
        }
        env {
          name  = "AZURE_STORAGE_ACCOUNT"
          value = var.storage_acct_name
        }
        env {
          name        = "AZURE_STORAGE_SAS"
          secret_name = local.secret_name_storage_sas
        }
        env {
          name        = "AZURE_STORAGE_CONN"
          secret_name = local.secret_name_storage_conn
        }
        env {
          name  = "AZURE_STORAGE_ACCOUNT_TYPE"
          value = "block"
        }
        env {
          name  = "AZURE_STORAGE_AUTH_TYPE"
          value = "Key"
        }
        env {
          name  = "AZURE_STORAGE_ACCOUNT_CONTAINER"
          value = var.storage_container_name
        }

        env {
          name  = "AZURE_STORAGE_BLOB_ENDPOINT"
          value = var.storage_blob_endpoint
        }

        env {
          name  = "KEY_VAULT_ID"
          value = var.key_vault_id
        }
        env {
          name  = "KEY_VAULT_NAME"
          value = var.key_vault_name
        }
      }
    }

    container {
      name   = "nginx"
      image  = "nginx:alpine"
      cpu    = 0.25
      memory = "0.5Gi"
    }

    volume {
      name         = local.app_volume
      storage_name = local.datahub_app_fileshare
      storage_type = "AzureFile"
    }
  }

  dynamic "secret" {
    for_each = var.container_app_secrets

    content {
      name                = lower(secret.value.name)
      identity            = azurerm_user_assigned_identity.proj_aca_uami.id
      key_vault_secret_id = secret.value.secret_id
    }
  }

  secret {
    name                = local.secret_name_storage_key
    identity            = azurerm_user_assigned_identity.proj_aca_uami.id
    key_vault_secret_id = var.storage_key_secret_id
  }
  secret {
    name                = local.secret_name_storage_sas
    identity            = azurerm_user_assigned_identity.proj_aca_uami.id
    key_vault_secret_id = var.storage_sas_secret_id
  }
  secret {
    name                = local.secret_name_storage_conn
    identity            = azurerm_user_assigned_identity.proj_aca_uami.id
    key_vault_secret_id = var.storage_conn_secret_id
  }

  ingress {
    external_enabled = true
    target_port      = var.container_ingress_port
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
