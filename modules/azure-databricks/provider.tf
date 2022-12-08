terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
  }
}

provider "databricks" {
  azure_workspace_resource_id = azurerm_databricks_workspace.datahub_databricks_workspace.id
  azure_use_msi               = var.run_in_devops
}

