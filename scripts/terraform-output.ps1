
# You can write your azure powershell scripts inline here. 
# You can also pass predefined and custom variables to this script using arguments
Write-Host "SSC_CHANGED_PROJECTS=" $(SSC_CHANGED_PROJECTS)
Write-Host "SSC_ADDITIONAL_PROJECTS=" $(SSC_ADDITIONAL_PROJECTS)

$env:ARM_ACCESS_KEY = Get-AzKeyVaultSecret -VaultName spdatahub-key-sand -Name fsdh-test-terraform-backend -AsPlainText

$project_list_csv = "$(SSC_CHANGED_PROJECTS)"
if (![string]::IsNullOrEmpty("$(SSC_ADDITIONAL_PROJECTS)")) { $project_list_csv += "," + "$(SSC_ADDITIONAL_PROJECTS)" }

$project_list = ($project_list_csv -split ",")
foreach ($project in $project_list) {
  write-host "FSDH: Processing project $project"
  terraform --version
  Push-Location $project
  
  $storage = Get-AzStorageAccount -ResourceGroupName $(OUTPUT_QUEUE_RESOURCE_GROUP_NAME) -Name $(OUTPUT_QUEUE_STORAGE_ACCOUNT_NAME)
  $queue = Get-AzStorageQueue -Name $(OUTPUT_QUEUE_NAME) -Context $storage.Context
  $outputJson = terraform output --json
  $queueMessage = [Microsoft.Azure.Storage.Queue.CloudQueueMessage]::new($outputJson)
  $queue.CloudQueue.AddMessageAsync($queueMessage)
  Write-Output "Sent message to queue for $project"
  
  Pop-Location
}
