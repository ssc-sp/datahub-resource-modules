# [Template] New Project Template

## Overview

This template is the starting point for a Datahub project. It references the [Azure Resource Group](https://github.com/ssc-sp/datahub-resource-modules/tree/main/modules/azure-resource-group) module.

## Template Usage

Copy all files in the template directory to a new project directory and generate the

## Template Variables

You will need to generate the following variables in a file when copying the template in order to use it:

| Name                       | Description                                            | Type                              | Default           | Required |
| -------------------------- | ------------------------------------------------------ | --------------------------------- | ----------------- | :------: |
| az_subscription_id         | The Azure subscription ID                              | `string`                          | -                 |   yes    |
| az_tenant_id               | The Azure tenant ID                                    | `string`                          | -                 |   yes    |
| project_cd                 | The unique project identifer                           | `string`                          | -                 |   yes    |
| environment_classification | Max level of security for the environment hosts        | `string`                          | `"U"`             |    no    |
| environment_name           | The name of the environment                            | `string`                          | `"dev"`           |    no    |
| az_location                | The Azure location to create the resources in          | `string`                          | `"canadacentral"` |    no    |
| resource_prefix            | A prefix to add to all resources                       | `string`                          | `"fsdh"`          |    no    |
| common_tags                | A map of common tags to apply to all project resources | `map(object({ value = string }))` | `{}`              |    no    |
