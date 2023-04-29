
param (
    [Parameter(Position=0)][string]$trigger_percent = "${trigger_percent}"
)

$resource_group_name = "${resource_group_name}"
$key_vault_name = "${key_vault_name}"
$budget_name = "${budget_name}"

Connect-AzAccount -Identity -Subscription "${subscription_id}"

$currentSpend = (Get-AzConsumptionBudget -Name $budget_name).currentspend.amount
$budgetAmount = (Get-AzConsumptionBudget -Name $budget_name).Amount

Write-Output "Current spend for RG: $resource_group_name is $currentSpend (trigger is $trigger_percent percent)"
if ($currentSpend -ge ($budgetAmount * $trigger_percent / 100)) {
    Write-Output "Disabling CMK in AKV $key_vault_name"

    Update-AzKeyVaultKey -VaultName "$key_vault_name" -Name 'project-cmk' -Enable $false
}

Write-Output "Completed"
