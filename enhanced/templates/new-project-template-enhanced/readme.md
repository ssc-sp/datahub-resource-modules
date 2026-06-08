# [Template] New Project Template

## Overview

This template is the starting point for a Datahub project. It references the [Azure Resource Group](https://github.com/ssc-sp/datahub-resource-modules/tree/main/modules/azure-resource-group) module.

## Template Usage

Copy all files in the template directory to a new project directory and generate the template variables in a file called `<template-name>.auto.tfvars` (or `<template-name>.auto.tfvars.json`) in the project directory. Then run `terraform init` and `terraform apply` to create the resources.

## Template Variables

You will need to generate the following variables in a file when copying the template in order to use it:

| Name                       | Description                                            | Type                              | Default           | Required |
| -------------------------- | ------------------------------------------------------ | --------------------------------- | ----------------- | :------: |
| az_subscription_id         | The Azure subscription ID                              | `string`                          | -                 |   yes    |
| az_tenant_id               | The Azure tenant ID                                    | `string`                          | -                 |   yes    |
| project_cd                 | The unique project identifer                           | `string`                          | -                 |   yes    |
| datahub_app_sp_oid         | The object ID of the service principal to use          | `string`                          | -                 |   yes    |
| environment_classification | Max level of security for the environment hosts        | `string`                          | `"U"`             |    no    |
| environment_name           | The name of the environment                            | `string`                          | `"dev"`           |    no    |
| az_location                | The Azure location to create the resources in          | `string`                          | `"canadacentral"` |    no    |
| resource_prefix            | A prefix to add to all resources                       | `string`                          | `"fsdh"`          |    no    |
| common_tags                | A map of common tags to apply to all project resources | `map(object({ value = string }))` | `{}`              |    no    |

## Sample Values

```hcl
az_subscription_id = "00000000-0000-0000-0000-000000000000"
az_tenant_id = "00000000-0000-0000-0000-000000000000"

project_cd = "CODE123"
datahub_app_sp_oid = "00000000-0000-0000-0000-000000000000"
environment_name = "dev"

environment_classification = "U"
az_location = "canadacentral"
resource_prefix = "fsdh"

common_tags = {
  "tag1" = "value1"
  "tag2" = "value2"
}
```
