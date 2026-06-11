resource "azurerm_container_app" "proj_container_app" {
  name                         = "${var.project_cd}-${var.environment_name}-aca-app"
  container_app_environment_id = var.aca_env_id
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
    ignore_changes = [tags]
  }
}
