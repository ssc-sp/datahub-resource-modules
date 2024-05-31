$key_vault_name = "${key_vault_name}"

Write-Output "Disabling CMK in AKV $key_vault_name"

Connect-AzAccount -Identity -AccountId "${uai_clientid}" -Subscription "${subscription_id}"
Update-AzKeyVaultKey -VaultName "$key_vault_name" -Name 'project-cmk' -Enable $false
Write-Output "Completed"
