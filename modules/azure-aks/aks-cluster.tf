resource "random_pet" "ssh_key_name" {
  prefix    = local.aks_ssh_key_name
  separator = ""
}

resource "azapi_resource_action" "ssh_public_key_gen" {
  type        = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  resource_id = azapi_resource.ssh_public_key.id
  action      = "generateKeyPair"
  method      = "POST"

  response_export_values = ["publicKey", "privateKey"]
}

resource "azapi_resource" "ssh_public_key" {
  type      = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  name      = random_pet.ssh_key_name.id
  parent_id = data.azurerm_resource_group.az_project_rg.id
  location  = var.az_location
}

output "key_data" {
  value = azapi_resource_action.ssh_public_key_gen.output.publicKey
}

resource "azurerm_kubernetes_cluster" "datahub_aks" {
  location            = var.az_location
  name                = "${local.aks_cluster_name}aks"
  resource_group_name = var.resource_group_name
  dns_prefix          = "${local.aks_cluster_name}dns"

  identity { type = "SystemAssigned" }

  default_node_pool {
    name       = "agentpool"
    vm_size    = "Standard_D2s_v4"  
    node_count = 1
    temporary_name_for_rotation = "tmpagentpool"
  }
  linux_profile {
    admin_username = local.aks_admin_name

    ssh_key {
      key_data = azapi_resource_action.ssh_public_key_gen.output.publicKey
    }
  }
  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }
}

resource "kubernetes_storage_class" "datahub_container_storage" {
  metadata { name = "azure-container-storage" }
  storage_provisioner = "disk.csi.azure.com"
  reclaim_policy      = "Retain"
  volume_binding_mode = "WaitForFirstConsumer"
  parameters          = { skuname = "Premium_LRS" }
}

resource "kubernetes_storage_class" "datahub_azure_files" {
  metadata { name = "azure-file-csi" }
  storage_provisioner = "file.csi.azure.com"
  reclaim_policy      = "Retain"
  volume_binding_mode = "Immediate"
  parameters          = { skuname = "Premium_LRS" }
}
