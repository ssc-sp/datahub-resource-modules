$PSScriptRoot
$cwd = Get-Location

cp $PSScriptRoot/../../templates/azure-databricks/*tf* . -Force
cp $PSScriptRoot/../../templates/azure-app-service/*tf* . -Force
cp $PSScriptRoot/../../templates/azure-storage-blob/*tf* . -Force
cp $PSScriptRoot/../../templates/new-project-template/*tf* . -Force

$file = 'azure-databricks.tf'; (Get-Content $file) -replace '^.*modules/azure-databricks.*', '  source = "../../modules/azure-databricks"' | Set-Content $file
$file = 'azure-storage-blob.tf'; (Get-Content $file) -replace '^.*modules/azure-storage-blob.*', '  source = "../../modules/azure-storage-blob"' | Set-Content $file
$file = 'azure-app-service.tf'; (Get-Content $file) -replace '^.*modules/azure-app-service.*', '  source = "../../modules/azure-app-service"' | Set-Content $file
$file = 'main.tf'; (Get-Content $file) -replace '^.*modules/azure-resource-group.*', '  source = "../../modules/azure-resource-group"' | Set-Content $file
