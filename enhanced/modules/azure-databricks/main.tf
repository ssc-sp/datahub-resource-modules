resource "azurerm_databricks_workspace" "datahub_databricks_workspace" {
  name                                  = local.databricks_name
  resource_group_name                   = var.resource_group_name
  managed_resource_group_name           = local.databricks_rg_name
  location                              = local.resource_group_location
  sku                                   = "premium"
  customer_managed_key_enabled          = true
  infrastructure_encryption_enabled     = true
  public_network_access_enabled         = local.public_access
  network_security_group_rules_required = local.public_access ? "AllRules" : "NoAzureDatabricksRules"

  custom_parameters {
    no_public_ip                                         = !var.is_dev
    virtual_network_id                                   = data.azurerm_virtual_network.datahub_vnet.id
    public_subnet_name                                   = var.dbr_subnet_public
    public_subnet_network_security_group_association_id  = data.azurerm_subnet.datahub_subnet_dbrpub.id
    private_subnet_name                                  = var.dbr_subnet_private
    private_subnet_network_security_group_association_id = data.azurerm_subnet.datahub_subnet_dbrprv.id
  }

  tags = var.project_tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "databricks_workspace_conf" "datahub_databricks_workspace_conf" {
  custom_config = {
    "enableTokensConfig" : true
  }
}

resource "null_resource" "datahub_databricks_protected_b" {
  provisioner "local-exec" {
    interpreter = ["pwsh", "-Command"]
    command     = <<-EOT
      $subscriptionId="${var.az_subscription_id}"
      $param=@{
        ResourceGroupName="${var.resource_group_name}"
        Name="${azurerm_databricks_workspace.datahub_databricks_workspace.name}"
        EnhancedSecurityCompliance="Enabled"
        ComplianceStandard=@("CANADA_PROTECTED_B")
        EnhancedSecurityMonitoring="Enabled"
        AutomaticClusterUpdate="Enabled"
      }
      update-azDatabricksWorkspace -subscriptionid $subscriptionId @param
    EOT
  }
}

# data "azurerm_resource_group" "az_project_rg" {
#   name = var.resource_group_name
# }

# data "azapi_resource_id" "datahub_databricks_rg" {
#   type      = "Microsoft.Resources/resourceGroups@2025-08-01-preview"
#   parent_id = data.azurerm_resource_group.az_project_rg.id
#   name      = "simontests2602labcdefgh"
# }

# resource "azapi_resource" "datahub_databricks_workspace" {
#   type      = "Microsoft.Databricks/workspaces@2025-08-01-preview"
#   name      = "${local.databricks_name}-1"
#   parent_id = data.azurerm_resource_group.az_project_rg.id
#   location  = local.resource_group_location
#   tags      = var.project_tags

#   body = {
#     properties = {
#       managedResourceGroupId = data.azapi_resource_id.datahub_databricks_rg.id

#       parameters = {
#         prepareEncryption               = { value = true }
#         requireInfrastructureEncryption = { value = true }
#         customVirtualNetworkId          = { value = data.azurerm_virtual_network.datahub_vnet.id }
#         customPublicSubnetName          = { value = var.dbr_subnet_public }
#         customPrivateSubnetName         = { value = var.dbr_subnet_private }
#       }
#       publicNetworkAccess = "Enabled"

#     }
#     sku = { name = "premium" }
#   }
#   schema_validation_enabled = false
#   response_export_values    = ["*"]
# }
