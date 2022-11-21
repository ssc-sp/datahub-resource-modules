
terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
  }
}
provider "databricks" {
  azure_workspace_resource_id = var.databricks_workspace_id
  azure_use_msi               = var.run_in_devops
}
