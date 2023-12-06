
param (
    [Parameter(Position = 0)][string]$version
)

$pathPrefix = ""
if (![string]::IsNullOrEmpty($version)) {
    $pathPrefix = "/$version"
}
$PSScriptRoot
$cwd = Get-Location


Copy-Item $PSScriptRoot/../../templates/azure-databricks/*tf* . -Force
Copy-Item $PSScriptRoot/../../templates/azure-app-service/*tf* . -Force
Copy-Item $PSScriptRoot/../../templates/azure-storage-blob/*tf* . -Force
Copy-Item $PSScriptRoot/../../templates/azure-mysql/*tf* . -Force
Copy-Item $PSScriptRoot/../../templates/azure-postgresql/*tf* . -Force
Copy-Item $PSScriptRoot/../../templates/new-project-template/*tf* . -Force
Copy-Item $PSScriptRoot/../../templates/azure-batch/*tf* . -Force

$file = 'azure-databricks.tf'; (Get-Content $file) -replace '^.*modules/', '  source = "../../modules/' -replace '{{version}}', "$version" -replace '{{branch}}', '' | Set-Content $file
$file = 'azure-storage-blob.tf'; (Get-Content $file) -replace '^.*modules/', '  source = "../../modules/' -replace '{{version}}', "$version" -replace '{{branch}}', '' | Set-Content $file
$file = 'azure-app-service.tf'; (Get-Content $file) -replace '^.*modules/', '  source = "../../modules/' -replace '{{version}}', "$version" -replace '{{branch}}', '' | Set-Content $file
$file = 'azure-mysql.tf'; (Get-Content $file) -replace '^.*modules/', '  source = "../../modules/' -replace '{{version}}', "$version" -replace '{{branch}}', '' | Set-Content $file
$file = 'azure-postgresql.tf'; (Get-Content $file) -replace '^.*modules/', '  source = "../../modules/' -replace '{{version}}', "$version" -replace '{{branch}}', '' | Set-Content $file
$file = 'azure-batch.tf'; (Get-Content $file) -replace '^.*modules/', '  source = "../../modules/' -replace '{{version}}', "$version" -replace '{{branch}}', '' | Set-Content $file
$file = 'main.tf'; (Get-Content $file) -replace '^.*modules/', '  source = "../../modules/' -replace '{{version}}', "$version" -replace '{{branch}}', '' | Set-Content $file

# Get my IP to whitelist for app service
$file = 'azure-app-service.tf'; (Get-Content $file) -replace 'var.allow_source_ip', 'data.http.myip.response_body' | Set-Content $file