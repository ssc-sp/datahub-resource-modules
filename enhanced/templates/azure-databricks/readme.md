# [Template] Azure Databricks

## Overview

This template is what references the [Azure Databricks](https://github.com/ssc-sp/datahub-resource-modules/tree/main/modules/azure-databricks) module.

## Template Usage

Copy all files in the template directory to a new project directory and generate the template variables in a file called `<template-name>.auto.tfvars` (or `<template-name>.auto.tfvars.json`) in the project directory. Then run `terraform init` and `terraform apply` to create the resources.

## Template Variables

You will need to generate the following variables in a file when copying the template in order to use it:

| Name                            | Description                                                        | Type        | Default   | Required |
| ------------------------------- | ------------------------------------------------------------------ | ----------- | --------- | :------: |
| databricks_admin_users          | The list of user objects with contributor role                     | `list(any)` | see below |    no    |
| azure_databricks_enterprise_oid | The object ID of the Azure Databricks Enterprise service principal | `string`    | -         |   yes    |

### Sample Values

```hcl
databricks_admin_users = [
  {
    email = "example@email.com"
  },
]

azure_databricks_enterprise_oid = "00000000-0000-0000-0000-000000000000"
```
