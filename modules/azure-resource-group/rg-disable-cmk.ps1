
param (
    [Parameter(Position=0)][string]$key_vault_name = "${key_vault_name}"
)


Write-Host "Disabling CMK in AKV $key_vault_name"

Connect-AzAccount -Identity
Update-AzKeyVaultKey -VaultName "$key_vault_name" -Name 'project-cmk' -Enable $false
