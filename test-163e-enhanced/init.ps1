$PSScriptRoot
$cwd = Get-Location

$allTemplates = @(
    "azure-databricks",
    # "azure-app-service",
    # "zure-postgres",
    "azure-container-app",
    # "azure-container-instance",
    "new-project-template"
)

foreach ($template in $allTemplates) { cp $PSScriptRoot/../templates/$template/*tf* . -Force }

$allModules = @('azure-databricks.tf', 'azure-app-service.tf', 'azure-postgresql.tf', 'azure-container-app.tf', 'azure-container-instance.tf', 'main.tf')
foreach ($module in $allModules) {
    if (Test-Path -Path $module) { (Get-Content $module) -replace '^.*modules/', '  source = "../modules/' -replace '{{tag}}', '' | Set-Content $module }
}

# Get my IP to whitelist for app service
$file = 'azure-app-service.tf'
if (Test-Path -Path $file) { (Get-Content $file) -replace 'var.allow_source_ip', 'trimspace("${data.http.myip.response_body}")' | Set-Content $file }
