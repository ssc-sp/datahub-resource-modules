data "databricks_catalogs" "all" {
  depends_on = [azurerm_databricks_workspace.datahub_databricks_workspace]
}

locals {
  built_in_catalog_name = [for catalog in data.databricks_catalogs.all.ids : catalog if catalog == replace(local.databricks_name, "-", "_")][0]
}

data "databricks_catalog" "datahub_proj_catalog" {
  name = local.built_in_catalog_name
}

resource "databricks_default_namespace_setting" "datahub_proj_catalog_default" {
  namespace {
    value = data.databricks_catalog.datahub_proj_catalog.name
  }
}

resource "databricks_schema" "datahub_proj_schema_bronze" {
  catalog_name = data.databricks_catalog.datahub_proj_catalog.name
  name         = "bronze"
}

resource "databricks_schema" "datahub_proj_schema_silver" {
  catalog_name = data.databricks_catalog.datahub_proj_catalog.name
  name         = "silver"
}

resource "databricks_schema" "datahub_proj_schema_gold" {
  catalog_name = data.databricks_catalog.datahub_proj_catalog.name
  name         = "gold"
}

resource "azurerm_databricks_access_connector" "datahub_workspace_storage" {
  name                = format("%s-connector", local.databricks_name)
  resource_group_name = var.resource_group_name
  location            = local.resource_group_location

  identity {
    type = "SystemAssigned"
  }

  tags = var.project_tags
}

resource "databricks_storage_credential" "datahub_workspace_storage" {
  name = format("%s-cred", local.databricks_name)
  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.datahub_workspace_storage.id
  }
  isolation_mode = "ISOLATION_MODE_ISOLATED"
  force_update   = true
  comment        = "Managed identity credential"
}

resource "databricks_external_location" "datahub_workspace_location" {
  name            = format("%s-ex-location", local.databricks_name)
  url             = format("abfss://%s@%s.dfs.core.windows.net/", local.datahub_blob_container, var.storage_acct_name)
  credential_name = databricks_storage_credential.datahub_workspace_storage.id
  comment         = "Managed by TF"
  isolation_mode  = "ISOLATION_MODE_ISOLATED"

  depends_on = [azurerm_role_assignment.datahub_storage_blob_contrib, azurerm_role_assignment.datahub_storage_acct_contrib, azurerm_role_assignment.datahub_storage_queue_contrib, azurerm_role_assignment.datahub_storage_eventgrid_contrib]
}

resource "databricks_external_location" "datahub_catalog_location" {
  name            = format("%s-catalog", local.databricks_name)
  url             = format("abfss://%s@%s.dfs.core.windows.net/", local.datahub_catalog_container, var.storage_acct_name)
  credential_name = databricks_storage_credential.datahub_workspace_storage.id
  comment         = "Managed by TF"
  isolation_mode  = "ISOLATION_MODE_ISOLATED"

  depends_on = [azurerm_role_assignment.datahub_storage_blob_contrib, azurerm_role_assignment.datahub_storage_acct_contrib, azurerm_role_assignment.datahub_storage_queue_contrib, azurerm_role_assignment.datahub_storage_eventgrid_contrib]
}

resource "databricks_grants" "grants_external_location" {
  external_location = databricks_external_location.datahub_workspace_location.id
  grant {
    principal  = jsondecode(data.http.get_group_lead.response_body).Resources[0].displayName
    privileges = local.location_privilege_lead
  }
  grant {
    principal  = jsondecode(data.http.get_group_user.response_body).Resources[0].displayName
    privileges = local.location_privilege_user
  }
  grant {
    principal  = jsondecode(data.http.get_group_guest.response_body).Resources[0].displayName
    privileges = local.location_privilege_guest
  }
}

resource "databricks_grants" "grants_catalog" {
  catalog = data.databricks_catalog.datahub_proj_catalog.id
  grant {
    principal  = jsondecode(data.http.get_group_lead.response_body).Resources[0].displayName
    privileges = local.catalog_privilege_lead
  }
  grant {
    principal  = jsondecode(data.http.get_group_user.response_body).Resources[0].displayName
    privileges = local.catalog_privilege_user
  }
  grant {
    principal  = jsondecode(data.http.get_group_guest.response_body).Resources[0].displayName
    privileges = local.catalog_privilege_guest
  }
  grant {
    principal  = data.azuread_service_principal.datahub_ado_sp.client_id
    privileges = ["MANAGE"]
  }
}

resource "databricks_grants" "grants_schema_bronze" {
  schema = databricks_schema.datahub_proj_schema_bronze.id
  grant {
    principal  = jsondecode(data.http.get_group_lead.response_body).Resources[0].displayName
    privileges = local.schema_privilege_lead
  }
  grant {
    principal  = jsondecode(data.http.get_group_user.response_body).Resources[0].displayName
    privileges = local.schema_privilege_user
  }
  grant {
    principal  = jsondecode(data.http.get_group_guest.response_body).Resources[0].displayName
    privileges = local.schema_privilege_guest
  }
}

resource "databricks_grants" "grants_schema_silver" {
  schema = databricks_schema.datahub_proj_schema_silver.id
  grant {
    principal  = jsondecode(data.http.get_group_lead.response_body).Resources[0].displayName
    privileges = local.schema_privilege_lead
  }
  grant {
    principal  = jsondecode(data.http.get_group_user.response_body).Resources[0].displayName
    privileges = local.schema_privilege_user
  }
  grant {
    principal  = jsondecode(data.http.get_group_guest.response_body).Resources[0].displayName
    privileges = local.schema_privilege_guest
  }
}

resource "databricks_grants" "grants_schema_gold" {
  schema = databricks_schema.datahub_proj_schema_gold.id
  grant {
    principal  = jsondecode(data.http.get_group_lead.response_body).Resources[0].displayName
    privileges = local.schema_privilege_lead
  }
  grant {
    principal  = jsondecode(data.http.get_group_user.response_body).Resources[0].displayName
    privileges = local.schema_privilege_user
  }
  grant {
    principal  = jsondecode(data.http.get_group_guest.response_body).Resources[0].displayName
    privileges = local.schema_privilege_guest
  }
}
