# You can write your azure powershell scripts inline here. 
# You can also pass predefined and custom variables to this script using arguments
Write-Host "SSC_CHANGED_PROJECTS=" $(SSC_CHANGED_PROJECTS)
Write-Host "SSC_ADDITIONAL_PROJECTS=" $(SSC_ADDITIONAL_PROJECTS)

$env:ARM_ACCESS_KEY = Get-AzKeyVaultSecret -VaultName spdatahub-key-sand -Name fsdh-test-terraform-backend -AsPlainText
$env:ARM_CLIENT_ID = Get-AzKeyVaultSecret -VaultName spdatahub-key-sand -Name devops-client-id -AsPlainText
$env:ARM_CLIENT_SECRET = Get-AzKeyVaultSecret -VaultName spdatahub-key-sand -Name devops-client-secret -AsPlainText
$env:ARM_SUBSCRIPTION_ID = "bc4bcb08-d617-49f4-b6af-69d6f10c240b"
$env:ARM_TENANT_ID = "8c1a4d93-d828-4d0e-9303-fd3bd611c822"

$project_list_csv = "$(SSC_CHANGED_PROJECTS)"
if (![string]::IsNullOrEmpty("$(SSC_ADDITIONAL_PROJECTS)")) { $project_list_csv += "," + "$(SSC_ADDITIONAL_PROJECTS)" }

$project_list = ($project_list_csv -split ",")
foreach ($project in $project_list) {
    write-host "FSDH: Processing project $project"
    terraform --version
    pushd $project
    terraform apply --auto-approve
    popd
}



