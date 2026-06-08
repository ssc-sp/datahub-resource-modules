resource "azurerm_private_endpoint" "datahub_datalake_ep_blob" {
  name                = lower("${azurerm_storage_account.datahub_storageaccount.name}-blob-ep")
  location            = local.resource_group_location
  resource_group_name = azurerm_resource_group.az_project_rg.name
  subnet_id           = data.azurerm_subnet.datahub_subnet_pep.id

  private_service_connection {
    name                           = lower("${azurerm_storage_account.datahub_storageaccount.name}-blob-conn")
    private_connection_resource_id = azurerm_storage_account.datahub_storageaccount.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  lifecycle {
    ignore_changes = [tags, private_dns_zone_group] # DNS automatically updated by Ent cloud and must not update if name not changed
  }
}

resource "azurerm_private_endpoint" "datahub_datalake_ep_file" {
  name                = lower("${azurerm_storage_account.datahub_storageaccount.name}-file-ep")
  location            = local.resource_group_location
  resource_group_name = azurerm_resource_group.az_project_rg.name
  subnet_id           = data.azurerm_subnet.datahub_subnet_pep.id

  private_service_connection {
    name                           = lower("${azurerm_storage_account.datahub_storageaccount.name}-file-conn")
    private_connection_resource_id = azurerm_storage_account.datahub_storageaccount.id
    is_manual_connection           = false
    subresource_names              = ["file"]
  }

  lifecycle {
    ignore_changes = [tags, private_dns_zone_group] # DNS automatically updated by Ent cloud and must not update if name not changed
  }
}

resource "azurerm_private_endpoint" "datahub_datalake_ep_dfs" {
  name                = lower("${azurerm_storage_account.datahub_storageaccount.name}-dfs-ep")
  location            = local.resource_group_location
  resource_group_name = azurerm_resource_group.az_project_rg.name
  subnet_id           = data.azurerm_subnet.datahub_subnet_pep.id

  private_service_connection {
    name                           = lower("${azurerm_storage_account.datahub_storageaccount.name}-dfs-conn")
    private_connection_resource_id = azurerm_storage_account.datahub_storageaccount.id
    is_manual_connection           = false
    subresource_names              = ["dfs"]
  }

  lifecycle {
    ignore_changes = [tags, private_dns_zone_group] # DNS automatically updated by Ent cloud and must not update if name not changed
  }
}

resource "azurerm_private_endpoint" "datahub_datalake_ep_queue" {
  name                = lower("${azurerm_storage_account.datahub_storageaccount.name}-queue-ep")
  location            = local.resource_group_location
  resource_group_name = azurerm_resource_group.az_project_rg.name
  subnet_id           = data.azurerm_subnet.datahub_subnet_pep.id

  private_service_connection {
    name                           = lower("${azurerm_storage_account.datahub_storageaccount.name}-queue-conn")
    private_connection_resource_id = azurerm_storage_account.datahub_storageaccount.id
    is_manual_connection           = false
    subresource_names              = ["queue"]
  }

  lifecycle {
    ignore_changes = [tags, private_dns_zone_group] # DNS automatically updated by Ent cloud and must not update if name not changed
  }
}

resource "azurerm_private_endpoint" "datahub_datalake_ep_table" {
  name                = lower("${azurerm_storage_account.datahub_storageaccount.name}-table-ep")
  location            = local.resource_group_location
  resource_group_name = azurerm_resource_group.az_project_rg.name
  subnet_id           = data.azurerm_subnet.datahub_subnet_pep.id

  private_service_connection {
    name                           = lower("${azurerm_storage_account.datahub_storageaccount.name}-table-conn")
    private_connection_resource_id = azurerm_storage_account.datahub_storageaccount.id
    is_manual_connection           = false
    subresource_names              = ["table"]
  }

  lifecycle {
    ignore_changes = [tags, private_dns_zone_group] # DNS automatically updated by Ent cloud and must not update if name not changed
  }
}

resource "azurerm_private_endpoint" "datahub_kv_pep" {
  name                = "${azurerm_key_vault.az_proj_kv.name}-pep"
  location            = local.resource_group_location
  resource_group_name = azurerm_resource_group.az_project_rg.name
  subnet_id           = data.azurerm_subnet.datahub_subnet_pep.id

  private_service_connection {
    name                           = "${azurerm_key_vault.az_proj_kv.name}-pep-conn"
    private_connection_resource_id = azurerm_key_vault.az_proj_kv.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  lifecycle {
    ignore_changes = [private_dns_zone_group] # DNS automatically updated by Ent cloud and must not update if name not changed
  }
}

