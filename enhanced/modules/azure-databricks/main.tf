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

  # enhanced_security_compliance {
  #   compliance_security_profile_enabled   = true
  #   compliance_security_profile_standards = ["CANADA_PROTECTED_B"]
  # }

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

resource "azapi_update_resource" "canada_protected_b" {
  type        = "Microsoft.Databricks/workspaces@2025-08-01-preview"
  resource_id = azurerm_databricks_workspace.datahub_databricks_workspace.id

  body = {
    properties = {
      enhandedSecurityCompliance = {
        complianceSecurityProfile = { value = "Enabled" }
        complianceStandards       = ["CANADA_PROTECTED_B"]
      }
    }
  }
}
