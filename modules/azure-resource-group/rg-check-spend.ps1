
param (
    [Parameter(Position=0)][string]$trigger_percent = "${trigger_percent}"
)

$resource_group_name = "${resource_group_name}"
$key_vault_name = "${key_vault_name}"
$budget_name = "${budget_name}"

Connect-AzAccount -Identity -Subscription "${subscription_id}"

$budgetAmount = (Get-AzConsumptionBudget -name $budget_name).Amount
$currentSpendMain = (Get-AzConsumptionBudget -name $budget_name).currentspend.amount
$currentSpendDbr = (Get-AzConsumptionBudget -name fsdh_proj_sw5_sand_rg-budget-dbr).currentspend.amount

Write-Output "Current spend for RG: $resource_group_name is $currentSpendMain + $currentSpendDbr (trigger is $trigger_percent percent)"
if (($currentSpendMain * $currentSpendDbr )-ge ($budgetAmount * $trigger_percent / 100)) {
    Write-Output "Disabling CMK in AKV $key_vault_name"

    Update-AzKeyVaultKey -VaultName "$key_vault_name" -Name 'project-cmk' -Enable $false
}

Write-Output "Completed"
