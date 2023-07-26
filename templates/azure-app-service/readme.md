# [Template] Azure App Service

## Overview

This template is what references the [Azure Databricks](https://github.com/ssc-sp/datahub-resource-modules/tree/main/modules/azure-app-service) module.

## Template Usage

Copy all files in the template directory to a new project directory and generate the template variables in a file called `<template-name>.auto.tfvars` (or `<template-name>.auto.tfvars.json`) in the project directory. Then run `terraform init` and `terraform apply` to create the resources.

## Template Variables

You will need to generate the following variables in a file when copying the template in order to use it:

| Name                            | Description                                                        | Type        | Default   | Required |
| ------------------------------- | ------------------------------------------------------------------ | ----------- | --------- | :------: |
| ssl_cert_kv_id         | The ID of the AKV that holds the wildcard certificate                     | `string` | see below |    yes    |
| sp_client_id | The client ID of the app registration used for authentication | `string`    | -         |   yes    |

### Sample Values

```hcl
ssl_cert_kv_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-rg/providers/Microsoft.KeyVault/vaults/my-key"
sp_client_id = "00000000-0000-0000-0000-000000000000"
```
