$PSScriptRoot
$cwd = Get-Location

cp $PSScriptRoot/../templates/azure-databricks/*tf* . -Force
cp $PSScriptRoot/../templates/azure-app-service/*tf* . -Force
cp $PSScriptRoot/../templates/azure-storage-blob/*tf* . -Force
cp $PSScriptRoot/../templates/azure-postgres/*tf* . -Force
#cp $PSScriptRoot/../templates/azure-mysql/*tf* . -Force
#cp $PSScriptRoot/../templates/azure-cr/*tf* . -Force
cp $PSScriptRoot/../templates/new-project-template/*tf* . -Force

$file = 'azure-databricks.tf'; (Get-Content $file) -replace '^.*modules/', '  source = "../modules/' -replace '{{tag}}', '' | Set-Content $file
$file = 'azure-storage-blob.tf'; (Get-Content $file) -replace '^.*modules/', '  source = "../modules/' -replace '{{tag}}', '' | Set-Content $file
$file = 'azure-app-service.tf'; (Get-Content $file) -replace '^.*modules/', '  source = "../modules/' -replace '{{tag}}', '' | Set-Content $file
$file = 'azure-postgresql.tf'; (Get-Content $file) -replace '^.*modules/', '  source = "../modules/' -replace '{{tag}}', '' | Set-Content $file
#$file = 'azure-mysql.tf'; (Get-Content $file) -replace '^.*modules/', '  source = "../modules/' -replace '{{tag}}', '' | Set-Content $file
#$file = 'azure-cr.tf'; (Get-Content $file) -replace '^.*modules/', '  source = "../modules/' -replace '{{tag}}', '' | Set-Content $file
$file = 'main.tf'; (Get-Content $file) -replace '^.*modules/', '  source = "../modules/' -replace '{{tag}}', '' | Set-Content $file

# Get my IP to whitelist for app service
$file = 'azure-app-service.tf'; (Get-Content $file) -replace 'var.allow_source_ip', 'trimspace("${data.http.myip.response_body}")' | Set-Content $file