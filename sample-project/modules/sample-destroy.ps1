# This script destroys the sample project
# Usage: sample-destroy.ps1 -Force -NoPrompt

param (
    [switch]$Force,
    [switch]$NoPrompt
)

if ($Force) {
    if (!$NoPrompt){
        $confirm = Read-Host "Are you sure you want to destroy environment" $envName "? [y/n]"
        if ($confirm -ne "y") {
            exit 1
        }        
    }
    $autoApprove="-auto-approve"
}

$projectCode=[regex]::match(((Get-Content $pwd\sample.auto.tfvars.json -Raw | grep "project_cd" | Convertto-json)|convertfrom-json),'"project_cd": "(.*)".*').Groups[1].value
$envName=[regex]::match(((Get-Content $pwd\sample.auto.tfvars.json -Raw | grep "environment_name" | Convertto-json)|convertfrom-json),'"environment_name": "(.*)".*').Groups[1].value

for ($i=1; $i -le 1; $i++){ terraform destroy $autoApprove }
az keyvault key delete --name "project-cmk" --vault-name "fsdh-proj-$projectCode-$envName-kv"
for ($i=1; $i -le 1; $i++){ terraform destroy $autoApprove }

#terraform destroy $autoApprove --target module.main.module.appService.azurerm_key_vault_secret.secret_func_create_graph_user_url

