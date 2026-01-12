# [Module] Azure Storage Blob

## Overview

This module is the file storage module for a Datahub project. It creates a blob storage account and a default container in Azure along with the access policies that are required for the project.

## Module Usage

> In order to add this module, you must first apply the [Azure Resource Group](https://github.com/ssc-sp/datahub-resource-modules/tree/main/modules/azure-resource-group) module.

```hcl
module "azure_storage_blob_module" {
  source              = "github.com/ssc-sp/datahub-resource-modules/modules/azure-storage-blob"

  resource_group_name = module.resource_group_module.az_project_rg_name
  key_vault_id        = module.resource_group_module.az_project_kv_id
  key_vault_cmk_name  = module.resource_group_module.az_project_cmk

  az_tenant_id        = var.az_tenant
  az_subscription_id  = var.az_subscription
  project_cd          = var.project_cd

  # optional variables
}
```

## Module Inputs

| Name                       | Description                                                     | Type                              | Default           | Required |
| -------------------------- | --------------------------------------------------------------- | --------------------------------- | ----------------- | :------: |
| az_subscription_id         | The Azure subscription ID                                       | `string`                          | -                 |   yes    |
| az_tenant_id               | The Azure tenant ID                                             | `string`                          | -                 |   yes    |
| project_cd                 | The unique project identifer                                    | `string`                          | -                 |   yes    |
| resource_group_name        | The name of the existing resource group to create the resources | `string`                          | -                 |   yes    |
| key_vault_id               | The ID of the existing key vault to store the secrets           | `string`                          | -                 |   yes    |
| key_vault_cmk_name         | The name of the existing key vault key to encrypt the secrets   | `string`                          | -                 |   yes    |
| virus_scan_acl_function_id | The Azure Function ID for BlobVirusScanAclUpdater function      | `string`                          | -                 |   yes    |
| environment_classification | Max level of security for the environment hosts                 | `string`                          | `"U"`             |    no    |
| environment_name           | The name of the environment                                     | `string`                          | `"dev"`           |    no    |
| az_location                | The Azure location to create the resources in                   | `string`                          | `"canadacentral"` |    no    |
| resource_prefix            | A prefix to add to all resources                                | `string`                          | `"fsdh"`          |    no    |
| common_tags                | A map of common tags to apply to all project resources          | `map(object({ value = string }))` | `{}`              |    no    |
## Event Grid Configuration

This module automatically configures Event Grid to enable virus scanning workflows:

### Event Grid System Topic
A system topic is created for the storage account to capture blob lifecycle events.

### Virus Scan ACL Updater Subscription
An Event Grid subscription is configured to trigger the `BlobVirusScanAclUpdater` Azure Function when:
- **Event Types**: `Microsoft.Storage.BlobPropertiesUpdated` and `Microsoft.Storage.BlobMetadataUpdated`
- **Subject Filter**: Only blobs in the `datahub/upload/` path
- **Trigger**: When ClamAV updates the `dh:scanStatus` metadata after scanning

The function automatically:
1. Validates the scan status is "Clean"
2. Applies read ACLs to workspace members
3. Updates blob metadata with access information
4. Sends email notifications to file uploaders

**Required**: You must provide the `virus_scan_acl_function_id` variable pointing to your deployed BlobVirusScanAclUpdater function.

## Module Outputs

| Name                         | Description                                              |
| ---------------------------- | -------------------------------------------------------- |
| storage_acct_name            | The name of the created storage account                  |
| azure_storage_account_id     | The Azure resource ID of the storage account             |
| eventgrid_system_topic_id    | The ID of the Event Grid System Topic                    |
| virus_scan_subscription_id   | The ID of the virus scan Event Grid subscription         |