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

for ($i=1; $i -le 1; $i++){ terraform destroy $autoApprove }
az keyvault key delete --name "project-cmk" --vault-name "fsdh-proj-sw2-sw2-kv"
for ($i=1; $i -le 1; $i++){ terraform destroy $autoApprove }

#terraform destroy $autoApprove --target module.main.module.appService.azurerm_key_vault_secret.secret_func_create_graph_user_url

