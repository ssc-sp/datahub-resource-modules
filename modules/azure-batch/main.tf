resource "azurerm_batch_account" "datahub_batch_acct" {
  name                                = local.batch_acct_name
  resource_group_name                 = var.resource_group_name
  location                            = local.resource_group_location
  pool_allocation_mode                = "BatchService"
  storage_account_id                  = var.storage_acct_id
  storage_account_authentication_mode = "BatchAccountManagedIdentity"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.datahub_batch_uami.id]
  }
  tags = merge(local.project_tags)
}

resource "azurerm_batch_pool" "datahub_batch_default_pool" {
  name                = local.batch_pool_name
  resource_group_name = var.resource_group_name
  account_name        = azurerm_batch_account.datahub_batch_acct.name
  display_name        = local.batch_pool_display_name
  vm_size             = var.batch_default_vm_sku
  node_agent_sku_id   = "batch.node.ubuntu 20.04"

  fixed_scale {
    target_dedicated_nodes = 0
  }

  storage_image_reference {
    publisher = "microsoft-azure-batch"
    offer     = "ubuntu-server-container"
    sku       = "20-04-lts"
    version   = "latest"
  }

  container_configuration {
    type                  = "DockerCompatible"
    container_image_names = ["${var.batch_starter_image_url}"]
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.datahub_batch_uami.id]
  }
  mount {
    azure_blob_file_system {
      account_name        = var.storage_acct_name
      identity_id         = azurerm_user_assigned_identity.datahub_batch_uami.id
      container_name      = "datahub"
      relative_mount_path = "datahub"
    }
  }

  start_task {
    command_line       = "echo 'Hello from FSDH'"
    task_retry_maximum = 1
    wait_for_success   = true

    user_identity {
      auto_user {
        elevation_level = "Admin"
        scope           = "Task"
      }
    }
  }
}
