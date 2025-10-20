resource "azurerm_kubernetes_cluster_extension" "container_storage" {
  name           = "containerstorage"
  cluster_id     = azurerm_kubernetes_cluster.datahub_aks.id
  extension_type = "microsoft.azurecontainerstorage"

  configuration_settings = {
    "storagePool.managedDisks.diskType"  = "Premium_LRS"
    "storagePool.managedDisks.diskSize"  = "512"
    "storagePool.managedDisks.diskCount" = "3"
    "storagePool.name"                   = "manageddiskpool"
    "storagePool.storagePoolType"        = "managedDisks"
  }
}

# resource "kubernetes_manifest" "storage_class" {
#   manifest = {
#     apiVersion = "storage.k8s.io/v1"
#     kind       = "StorageClass"
#     metadata   = { name = "azure-container-storage" }
#     parameters = {
#       storagePool     = "manageddiskpool"
#       storagePoolType = "managedDisks"
#     }
#     provisioner          = "containerstorage.csi.azure.com"
#     reclaimPolicy        = "Delete"
#     volumeBindingMode    = "Immediate"
#     allowVolumeExpansion = true
#   }

#   depends_on = [azurerm_kubernetes_cluster.datahub_aks]
# }
