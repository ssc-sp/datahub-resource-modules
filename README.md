# Datahub Resource Modules

Public repository containing terraform resource modules for Datahub.

## Template Structure

A template directory typically contains the following files:

- `readme.md` - A markdown file containing a description of the template and instructions for using it.
- `<template-name>.variables.tf.json` - A terraform file containing the variables used by only the template.
  > Note: The template variables file should not contain any variables that are used by more than one modules, except for the main resource group module.
- `<template-name>.tf` - A terraform file containing the resources created by the template, usually a reference to a module.


## Sample Message

```json
{
    "templates": [
        {
            "name": "new-project-template",
        },
        {
            "name": "azure-storage-blob",
        }
    ],
    "workspace": {
        "version": "latest",
        "name": "Workspance Name",
        "acronym": "WORK",
        "organization": {
            "name": "Just an Example",
            "code": "JaE"
        },
        "users":[
            {
                "objectId": "00000000-0000-0000-0000-000000000000",
                "email": "owner@email.com",
                "role": "Owner"
            },
            {
                "objectId": "00000000-0000-0000-0000-000000000000",
                "email": "admin@email.com",
                "role": "Admin"
            },
            {
                "objectId": "00000000-0000-0000-0000-000000000000",
                "email": "user@email.com",
                "role": "User"
            }
        ]
    },
    "requestingUserEmail": "unit@test.com"
}

```
