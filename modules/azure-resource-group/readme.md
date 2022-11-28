# [Module] Azure Resource Group

## Overview

This module is the initial module for a Datahub project. It creates a resource group in Azure along with any meta-resources that are required for the project.

## Module Usage

```hcl
module "resource_group_module" {
  source             = "github.com/ssc-sp/datahub-resource-modules/modules/azure-resource-group"

  az_tenant_id       = var.az_tenant
  az_subscription_id = var.az_subscription
  project_cd         = var.project_cd

  # optional variables
}
```

## Module Inputs

| Name                       | Description                                            | Type                              | Default           | Required |
| -------------------------- | ------------------------------------------------------ | --------------------------------- | ----------------- | :------: |
| az_subscription_id         | The Azure subscription ID                              | `string`                          | -                 |   yes    |
| az_tenant_id               | The Azure tenant ID                                    | `string`                          | -                 |   yes    |
| project_cd                 | The unique project identifer                           | `string`                          | -                 |   yes    |
| environment_classification | Max level of security for the environment hosts        | `string`                          | `"PA"`            |    no    |
| environment_name           | The name of the environment                            | `string`                          | `"prod"`          |    no    |
| az_location                | The Azure location to create the resources in          | `string`                          | `"canadacentral"` |    no    |
| resource_prefix            | A prefix to add to all resources                       | `string`                          | `"fsdh"`          |    no    |
| common_tags                | A map of common tags to apply to all project resources | `map(object({ value = string }))` | `{}`              |    no    |
