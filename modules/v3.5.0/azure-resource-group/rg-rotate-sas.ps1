# Rotate the SAS token in AKV (Secret name storage-sas)

$key_vault_name = "${key_vault_name}"
$sas_secret_name = "${sas_secret_name}"
$storage_acct_name = "${storage_acct_name}"
$resource_group_name = "${resource_group_name}"
$container_name = "${container_name}"

Connect-AzAccount -Identity -AccountId "${uai_clientid}" -Subscription "${subscription_id}"
$secret_start = (Get-AzKeyVaultSecret -VaultName $key_vault_name -Name $sas_secret_name).tags.start
$secret_expiry = (Get-AzKeyVaultSecret -VaultName $key_vault_name -Name $sas_secret_name).tags.expiry
Write-Output "Existing expiry date: from $secret_start to $secret_expiry"

if ((get-date).addDays(14) -ge (get-date $secret_expiry)) {
    $new_start = (get-date).addDays(-1).toString("yyyy-MM-dd")
    $new_expiry = (get-date).addDays(91).toString("yyyy-MM-dd")
    $new_tags = @{ "start" = "$new_start"; "expiry" = "$new_expiry" } 
    Write-Output "Rotating SAS token - generating a new SAS token"
    $context = (Get-AzStorageAccount -ResourceGroupName $resource_group_name -AccountName $storage_acct_name).context
    $new_sas = New-AzStorageContainerSASToken -Name $container_name -Permission rwd -StartTime $new_start -ExpiryTime $new_expiry -context $context
    $new_sas_secret = ConvertTo-SecureString -String "$new_sas" -AsPlainText -Force
    Set-AzKeyVaultSecret -VaultName $key_vault_name -Name $sas_secret_name -SecretValue $new_sas_secret -Tags $new_tags
    Write-Output "New expiry date: from $new_start to $new_expiry"
}

Write-Output "Completed"
