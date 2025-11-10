# Event Grid Blob Metadata Update Trigger

## Overview

This document describes the Terraform infrastructure added to automatically trigger the `BlobVirusScanAclUpdater` Azure Function when blob metadata changes occur in Azure Data Lake Storage Gen2.

## Changes Made

### 1. Event Grid Subscription (`modules/azure-storage-blob/event.tf`)

Added a new Event Grid subscription that listens for `Microsoft.Storage.BlobPropertiesUpdated` events:

```terraform
resource "azurerm_eventgrid_system_topic_event_subscription" "blob_metadata_updated_subscription" {
  name                  = "blobmetadataupdatedsubscription"
  system_topic          = azurerm_eventgrid_system_topic.project_blob_created_system_topic.name
  resource_group_name   = var.resource_group_name
  event_delivery_schema = "EventGridSchema"

  # Microsoft.Storage.BlobPropertiesUpdated is triggered when blob metadata changes
  included_event_types = ["Microsoft.Storage.BlobPropertiesUpdated"]

  azure_function_endpoint {
    function_id                       = var.virus_scan_acl_function_id
    max_events_per_batch              = 1
    preferred_batch_size_in_kilobytes = 64
  }

  subject_filter {
    subject_begins_with = "/blobServices/default/containers/${local.datahub_mount_name}/"
    case_sensitive      = false
  }

  retry_policy {
    max_delivery_attempts = 5
    event_time_to_live    = 1440
  }

  advanced_filter {
    string_begins_with {
      key    = "data.api"
      values = ["PutBlob", "PutBlockList", "CopyBlob", "SetBlobMetadata", "SetBlobProperties"]
    }
  }
}
```

**Key Features:**
- **Event Type**: `Microsoft.Storage.BlobPropertiesUpdated` - Fires when blob metadata or properties change
- **Endpoint**: Routes directly to Azure Function via `azure_function_endpoint`
- **Batching**: Processes one event at a time (`max_events_per_batch = 1`)
- **Subject Filter**: Only triggers for blobs in the workspace's datahub container
- **Advanced Filter**: Only triggers on specific API operations that can change metadata
- **Retry Policy**: 5 attempts over 24 hours if function is unavailable

### 2. Variable Definitions

#### Module Variable (`modules/azure-storage-blob/variables.tf`)

```terraform
variable "virus_scan_acl_function_id" {
  description = "Azure Function ID for the BlobVirusScanAclUpdater function that handles metadata change events"
  type        = string
}
```

#### Template Variable (`templates/azure-storage-blob/azure-storage-blob-template.variables.tf.json`)

```json
{
  "virus_scan_acl_function_id": {
    "type": "string",
    "description": "The Azure Function ID for the BlobVirusScanAclUpdater function (format: /subscriptions/{sub-id}/resourceGroups/{rg-name}/providers/Microsoft.Web/sites/{function-app-name}/functions/{function-name})"
  }
}
```

#### Template Module Call (`templates/azure-storage-blob/azure-storage-blob.tf`)

Added the variable to the module call:

```terraform
module "azure_storage_blob_module" {
  # ... other variables ...
  virus_scan_acl_function_id   = var.virus_scan_acl_function_id
  # ... other variables ...
}
```

## Function ID Format

The `virus_scan_acl_function_id` must be in the following format:

```
/subscriptions/{subscription-id}/resourceGroups/{resource-group-name}/providers/Microsoft.Web/sites/{function-app-name}/functions/BlobVirusScanAclUpdater
```

### Example

```
/subscriptions/bc4bcb08-d617-49f4-b6af-69d6f10c240b/resourceGroups/fsdh-serverless-dev-rg/providers/Microsoft.Web/sites/fsdh-functions-dev/functions/BlobVirusScanAclUpdater
```

### How to Obtain the Function ID

#### Using Azure CLI:

```bash
# Get the function app resource ID
FUNCTION_APP_ID=$(az functionapp show \
  --name <function-app-name> \
  --resource-group <resource-group-name> \
  --query id -o tsv)

# Append the function name
FUNCTION_ID="${FUNCTION_APP_ID}/functions/BlobVirusScanAclUpdater"
echo $FUNCTION_ID
```

#### Using PowerShell:

```powershell
# Get the function app resource ID
$functionAppId = az functionapp show `
  --name <function-app-name> `
  --resource-group <resource-group-name> `
  --query id -o tsv

# Append the function name
$functionId = "$functionAppId/functions/BlobVirusScanAclUpdater"
Write-Output $functionId
```

## Deployment Process

### 1. Configure Shared Infrastructure Variables

The `virus_scan_acl_function_id` should be added to the shared Terraform variables that are provided to all workspace deployments. This is typically done in the infrastructure repository's variable configuration.

**Example location**: `datahub-project-infrastructure-{env}/terraform/variables.tfvars` or similar

Add:

```hcl
virus_scan_acl_function_id = "/subscriptions/bc4bcb08-d617-49f4-b6af-69d6f10c240b/resourceGroups/fsdh-serverless-dev-rg/providers/Microsoft.Web/sites/fsdh-functions-dev/functions/BlobVirusScanAclUpdater"
```

### 2. Deploy the Function

Ensure the `BlobVirusScanAclUpdater` function is deployed to Azure Functions before applying the Terraform configuration:

```bash
# Deploy the function
cd ServerlessOperations/src/Datahub.Functions
func azure functionapp publish <function-app-name>
```

### 3. Apply Terraform Configuration

For new workspaces:
```bash
cd terraform/projects/<workspace-name>
terraform init
terraform apply
```

For existing workspaces:
```bash
cd terraform/projects/<workspace-name>
terraform apply
```

## Event Flow

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. ClamAV scans blob and sets metadata                         │
│    dh:scanStatus = "Clean"                                      │
└──────────────────┬──────────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────────┐
│ 2. Azure Storage fires BlobPropertiesUpdated event             │
│    Event Type: Microsoft.Storage.BlobPropertiesUpdated         │
└──────────────────┬──────────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────────┐
│ 3. Event Grid System Topic receives event                      │
│    Topic: {storage-account-name}blobcreatedtopic               │
└──────────────────┬──────────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────────┐
│ 4. Event Grid Subscription filters event                       │
│    - Container filter: /blobServices/.../datahub/              │
│    - API filter: SetBlobMetadata, etc.                         │
└──────────────────┬──────────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────────┐
│ 5. Event Grid delivers to Azure Function                       │
│    Endpoint: BlobVirusScanAclUpdater function                  │
└──────────────────┬──────────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────────┐
│ 6. Function validates dh:scanStatus = "Clean"                  │
│    - Extracts workspace acronym from blob path                │
│    - Queries database for workspace members                   │
└──────────────────┬──────────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────────┐
│ 7. Function updates blob ACLs                                  │
│    - Grants read access to all workspace members              │
│    - Uses Azure Data Lake Storage Gen2 ACL API               │
└─────────────────────────────────────────────────────────────────┘
```

## Comparison with Blob Created Trigger

| Feature | Blob Created Subscription | Metadata Updated Subscription |
|---------|---------------------------|------------------------------|
| **Event Type** | `Microsoft.Storage.BlobCreated` | `Microsoft.Storage.BlobPropertiesUpdated` |
| **Endpoint** | Storage Queue | Azure Function (direct) |
| **Purpose** | Queue blobs for ClamAV scanning | Update ACLs after successful scan |
| **Trigger** | File upload | Metadata change (scan complete) |
| **Batching** | Queue-based (configurable) | 1 event at a time |
| **Processing** | Async via queue consumer | Synchronous via function |

## Monitoring

### View Event Grid Metrics

```bash
# View delivery success rate
az monitor metrics list \
  --resource <event-grid-system-topic-id> \
  --metric "DeliverySuccessCount" \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-31T23:59:59Z
```

### View Function Logs

```kusto
traces
| where operation_Name == "BlobVirusScanAclUpdater"
| order by timestamp desc
| take 100
```

### View Event Grid Subscription Details

```bash
az eventgrid system-topic event-subscription show \
  --name blobmetadataupdatedsubscription \
  --system-topic-name <storage-account-name>blobcreatedtopic \
  --resource-group <resource-group-name>
```

## Troubleshooting

### Event Not Triggering

1. **Check function is deployed**:
   ```bash
   az functionapp function show \
     --name <function-app-name> \
     --resource-group <resource-group-name> \
     --function-name BlobVirusScanAclUpdater
   ```

2. **Verify subscription is active**:
   ```bash
   az eventgrid system-topic event-subscription show \
     --name blobmetadataupdatedsubscription \
     --system-topic-name <storage-account-name>blobcreatedtopic \
     --resource-group <resource-group-name> \
     --query provisioningState
   ```

3. **Check dead letter queue** (if configured):
   ```bash
   # View failed deliveries
   az storage queue peek \
     --name <dead-letter-queue> \
     --account-name <storage-account>
   ```

### Function Errors

Check Application Insights:

```kusto
exceptions
| where operation_Name == "BlobVirusScanAclUpdater"
| order by timestamp desc
| project timestamp, problemId, outerMessage, innermostMessage
```

## Security Considerations

1. **Function Authentication**: The Event Grid subscription uses system-assigned managed identity to authenticate to the function
2. **RBAC**: Ensure the Event Grid system topic has `Azure Event Grid EventSubscription Contributor` role
3. **Network Security**: Consider using private endpoints for Event Grid if required by your security policy

## Cost Implications

- **Event Grid Operations**: ~$0.60 per million operations
- **Function Executions**: Consumption plan pricing applies
- **Storage Transactions**: Metadata reads incur storage transaction costs

For a workspace with moderate activity (1000 file uploads/day), estimated monthly cost: <$5 USD

## References

- [Azure Event Grid Event Schema for Blob Storage](https://learn.microsoft.com/en-us/azure/event-grid/event-schema-blob-storage)
- [Azure Functions Event Grid Trigger](https://learn.microsoft.com/en-us/azure/azure-functions/functions-bindings-event-grid-trigger)
- [BlobVirusScanAclUpdater Function Documentation](../../datahub-portal/ServerlessOperations/src/Datahub.Functions/README_BlobVirusScanAclUpdater.md)
