resource "azapi_resource" "fsdh_databricks" {
  name      = local.databricks_name
  type      = "Microsoft.Databricks/workspaces@2025-08-01-preview"
  location  = local.resource_group_location
  parent_id = var.resource_group_id
  tags      = var.project_tags

  body = {
    sku = {
      name = "premium"
    }
    properties = {
      managedResourceGroupId = "${data.azurerm_subscription.az_subscription.id}/resourceGroups/${local.databricks_name}-rg"
      enhancedSecurityCompliance = {
        automaticClusterUpdate = {
          value = "Enabled"
        }
        complianceSecurityProfile = {
          complianceStandards = [
            "CANADA_PROTECTED_B"
          ]
          value = "Enabled"
        }
        enhancedSecurityMonitoring = {
          value = "Enabled"
        }
      }
      encryption = {
        entities = {
          managedDisk = {
            keySource = "Microsoft.Keyvault"
            keyVaultProperties = {
              keyName     = "${local.kv_key_name}"
              keyVaultUri = "${local.kv_uri}"
              keyVersion  = "${local.kv_key_version}"
            }
            rotationToLatestKeyVersionEnabled = true
          }
          managedServices = {
            keySource = "Microsoft.Keyvault"
            keyVaultProperties = {
              keyName     = "${local.kv_key_name}"
              keyVaultUri = "${local.kv_uri}"
              keyVersion  = "${local.kv_key_version}"
            }
          }
        }
      }
      requiredNsgRules    = "NoAzureDatabricksRules"
      publicNetworkAccess = "Enabled"
      parameters = {
        prepareEncryption = {
          type  = "Boolean"
          value = true
        }
        requireInfrastructureEncryption = {
          type  = "Boolean"
          value = true
        }
        customPrivateSubnetName = {
          type  = "String"
          value = var.dbr_subnet_private
        }
        customPublicSubnetName = {
          type  = "String"
          value = var.dbr_subnet_public
        }
        customVirtualNetworkId = {
          type  = "String"
          value = data.azurerm_virtual_network.datahub_vnet.id
        }
        enableNoPublicIp = {
          type  = "Bool"
          value = true
        }
      }
    }
  }

  response_export_values = ["properties.workspaceUrl", "name", "properties.workspaceId", "properties.managedResourceGroupId", "identity.principalId", "properties.storageAccountIdentity", "properties.managedDiskIdentity.principalId"]

  lifecycle {
    ignore_changes = [body.properties.publicNetworkAccess]
  }
}

resource "databricks_workspace_conf" "datahub_databricks_workspace_conf" {
  custom_config = {
    "enableTokensConfig" : true
  }
}
