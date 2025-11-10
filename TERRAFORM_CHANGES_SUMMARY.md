# Terraform Changes Summary - Blob Metadata Update Trigger

## Overview

Successfully added Terraform infrastructure code to the `datahub-resource-modules` repository to automatically subscribe to blob metadata change events and trigger the `BlobVirusScanAclUpdater` Azure Function.

## Files Modified

### 1. `modules/azure-storage-blob/event.tf`
**Change**: Added new Event Grid subscription resource

```terraform
resource "azurerm_eventgrid_system_topic_event_subscription" "blob_metadata_updated_subscription" {
  # Routes BlobPropertiesUpdated events to BlobVirusScanAclUpdater function
  # Filters for workspace container and specific API operations
  # Includes retry policy and advanced filtering
}
```

**Lines Added**: ~40 lines
**Purpose**: Creates Event Grid subscription that triggers when blob metadata changes

### 2. `modules/azure-storage-blob/variables.tf`
**Change**: Added required variable definition

```terraform
variable "virus_scan_acl_function_id" {
  description = "Azure Function ID for the BlobVirusScanAclUpdater function"
  type        = string
}
```

**Lines Added**: 4 lines
**Purpose**: Accepts the function ID parameter from parent template

### 3. `templates/azure-storage-blob/azure-storage-blob.tf`
**Change**: Added variable to module call

```terraform
module "azure_storage_blob_module" {
  # ... existing variables ...
  virus_scan_acl_function_id   = var.virus_scan_acl_function_id
  # ... other variables ...
}
```

**Lines Added**: 1 line
**Purpose**: Passes function ID from template variables to module

### 4. `templates/azure-storage-blob/azure-storage-blob-template.variables.tf.json`
**Change**: Added template variable definition

```json
{
  "virus_scan_acl_function_id": {
    "type": "string",
    "description": "The Azure Function ID for the BlobVirusScanAclUpdater function"
  }
}
```

**Lines Added**: 5 lines
**Purpose**: Defines the required template variable for workspace deployments

## Files Created

### 5. `EVENTGRID_METADATA_TRIGGER.md`
**Content**: Comprehensive documentation covering:
- Architecture and event flow
- Deployment instructions
- Function ID format and how to obtain it
- Monitoring and troubleshooting
- Comparison with existing blob created trigger
- Security and cost considerations

**Size**: ~300 lines
**Purpose**: Complete guide for deploying and managing the metadata trigger

## Technical Details

### Event Grid Configuration

| Property | Value |
|----------|-------|
| **Event Type** | `Microsoft.Storage.BlobPropertiesUpdated` |
| **Endpoint Type** | `azure_function_endpoint` (direct invocation) |
| **Batching** | 1 event per batch |
| **Subject Filter** | `/blobServices/default/containers/datahub/` |
| **API Filter** | PutBlob, PutBlockList, CopyBlob, SetBlobMetadata, SetBlobProperties |
| **Retry Policy** | 5 attempts, 24-hour TTL |

### Integration Points

1. **Reuses Existing System Topic**: Leverages `azurerm_eventgrid_system_topic.project_blob_created_system_topic`
2. **Workspace Isolation**: Subject filter ensures only workspace-specific blobs trigger the function
3. **Efficient Filtering**: Advanced filter reduces unnecessary function invocations

## Deployment Requirements

### Prerequisites

1. **Function Deployed**: `BlobVirusScanAclUpdater` must be deployed to Azure Functions
2. **Function ID Known**: Resource ID must be provided to Terraform
3. **Permissions**: Event Grid needs access to invoke the function

### Configuration Steps

1. **Deploy Azure Function**:
   ```bash
   cd ServerlessOperations/src/Datahub.Functions
   func azure functionapp publish <function-app-name>
   ```

2. **Get Function ID**:
   ```bash
   FUNCTION_APP_ID=$(az functionapp show --name <name> --resource-group <rg> --query id -o tsv)
   FUNCTION_ID="${FUNCTION_APP_ID}/functions/BlobVirusScanAclUpdater"
   ```

3. **Add to Infrastructure Variables**:
   In `datahub-project-infrastructure-{env}` repository:
   ```hcl
   virus_scan_acl_function_id = "<function-id-from-step-2>"
   ```

4. **Apply Terraform**:
   ```bash
   terraform apply
   ```

## Testing Verification

### Manual Test

1. Upload a blob to workspace storage
2. Set metadata via ClamAV or manually:
   ```bash
   az storage blob metadata update \
     --container-name datahub \
     --name <blob-path> \
     --metadata dh:scanStatus=Clean \
     --account-name <storage-account>
   ```
3. Check Application Insights for function execution logs

### Automated Monitoring

```kusto
traces
| where operation_Name == "BlobVirusScanAclUpdater"
| where message contains "Successfully updated ACLs"
| summarize count() by bin(timestamp, 1h)
```

## Rollback Plan

If issues occur:

1. **Disable Subscription**:
   ```bash
   az eventgrid system-topic event-subscription update \
     --name blobmetadataupdatedsubscription \
     --system-topic-name <topic> \
     --resource-group <rg> \
     --endpoint-type azurefunction \
     --endpoint "" \
     --enabled false
   ```

2. **Remove from Terraform** (if needed):
   Comment out the `blob_metadata_updated_subscription` resource

## Success Criteria

✅ Event Grid subscription created successfully  
✅ Function receives metadata change events  
✅ Function validates `dh:scanStatus = "Clean"`  
✅ ACLs updated for workspace members  
✅ No errors in Application Insights  
✅ Event delivery success rate > 99%  

## Next Steps

1. **Update Infrastructure Repository**: Add `virus_scan_acl_function_id` variable to shared configuration
2. **Deploy Changes**: Apply Terraform to test workspace first
3. **Monitor**: Watch Application Insights and Event Grid metrics for 24 hours
4. **Rollout**: Gradually apply to all workspaces via normal deployment process

## Related Documentation

- [BlobVirusScanAclUpdater Function README](../datahub-portal/ServerlessOperations/src/Datahub.Functions/README_BlobVirusScanAclUpdater.md)
- [EVENTGRID_METADATA_TRIGGER.md](./EVENTGRID_METADATA_TRIGGER.md) - Detailed deployment guide
- [Function Implementation Summary](../datahub-portal/ServerlessOperations/src/Datahub.Functions/IMPLEMENTATION_SUMMARY.md)

## Repository Structure

```
datahub-resource-modules/
├── modules/
│   └── azure-storage-blob/
│       ├── event.tf                    # ✨ MODIFIED: Added metadata subscription
│       └── variables.tf                # ✨ MODIFIED: Added function_id variable
├── templates/
│   └── azure-storage-blob/
│       ├── azure-storage-blob.tf       # ✨ MODIFIED: Pass function_id to module
│       └── azure-storage-blob-template.variables.tf.json  # ✨ MODIFIED: Added variable
├── EVENTGRID_METADATA_TRIGGER.md       # ✨ NEW: Deployment documentation
└── TERRAFORM_CHANGES_SUMMARY.md        # ✨ NEW: This file
```

## Questions or Issues?

Contact the infrastructure team or refer to the detailed documentation in `EVENTGRID_METADATA_TRIGGER.md`.
