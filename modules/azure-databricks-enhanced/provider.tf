terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "1.112.0"
    }
    azapi = {
      source = "azure/azapi"
    }
  }
}

provider "databricks" {
  azure_workspace_resource_id = azapi_resource.fsdh_databricks.id
}
