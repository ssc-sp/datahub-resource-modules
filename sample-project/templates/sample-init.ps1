
param (
    [Parameter(Position=0)][string]$version
)

$pathPrefix = ""
if (![string]::IsNullOrEmpty($version)) {
    $pathPrefix = "/$version"
}
$PSScriptRoot
$cwd = Get-Location


cp $PSScriptRoot/../../templates/azure-databricks/*tf* . -Force
cp $PSScriptRoot/../../templates/azure-app-service/*tf* . -Force
cp $PSScriptRoot/../../templates/azure-storage-blob/*tf* . -Force
cp $PSScriptRoot/../../templates/new-project-template/*tf* . -Force

$file = 'azure-databricks.tf'; (Get-Content $file) -replace '^.*modules/', '  source = "../../modules/' -replace '{{version}}', "$version" -replace '{{branch}}', '' | Set-Content $file
$file = 'azure-storage-blob.tf'; (Get-Content $file) -replace '^.*modules/', '  source = "../../modules/' -replace '{{version}}', "$version" -replace '{{branch}}', '' | Set-Content $file
$file = 'azure-app-service.tf'; (Get-Content $file) -replace '^.*modules/', '  source = "../../modules/' -replace '{{version}}', "$version" -replace '{{branch}}', '' | Set-Content $file
$file = 'main.tf'; (Get-Content $file) -replace '^.*modules/', '  source = "../../modules/' -replace '{{version}}', "$version" -replace '{{branch}}', '' | Set-Content $file

# Get my IP to whitelist for app service
$file = 'azure-app-service.tf'; (Get-Content $file) -replace 'var.allow_source_ip', 'data.http.myip.response_body' | Set-Content $file