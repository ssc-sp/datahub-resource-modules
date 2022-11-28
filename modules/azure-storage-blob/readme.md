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
| environment_classification | Max level of security for the environment hosts                 | `string`                          | `"U"`             |    no    |
| environment_name           | The name of the environment                                     | `string`                          | `"dev"`           |    no    |
| az_location                | The Azure location to create the resources in                   | `string`                          | `"canadacentral"` |    no    |
| resource_prefix            | A prefix to add to all resources                                | `string`                          | `"fsdh"`          |    no    |
| common_tags                | A map of common tags to apply to all project resources          | `map(object({ value = string }))` | `{}`              |    no    |
