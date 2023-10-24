# Resource module v2.13.0

## Migration procedure

This version removes user creation and delegates to the Python scripts outside Terraform. BEFORE upgrading to this version, users state must be removed. This leaves user accounts unchanged but removes the Terraform state for user accounts.

1. Login to Azure
2. Change directory to the project directory
3. Run the following:
    ```
    terraform state rm module.azure_databricks_module.databricks_user.datahub_dbk_user
    terraform state rm module.azure_databricks_module.databricks_group_member.datahub_dbk_admin_member
    terraform state rm module.azure_databricks_module.databricks_group_member.datahub_dbk_lead_member
    terraform state rm module.azure_databricks_module.databricks_group_member.datahub_dbk_all_member
    terraform state rm module.azure_storage_blob_module.azurerm_role_assignment.storage_contributor_assignment
    terraform state rm module.azure_storage_blob_module.azurerm_role_assignment.storage_reader_assignment     
    ```
4. Upgrade the project to use this new version
5. Run: `terraform init`
6. Run: `terraform plan`