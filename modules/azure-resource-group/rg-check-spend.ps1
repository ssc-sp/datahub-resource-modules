
param (
    [Parameter(Position = 0)][string]$trigger_percent = "${trigger_percent}"
)

$key_vault_name = "${key_vault_name}"
$budget_name = "${budget_name}"
$budget_name_dbr = "${budget_name_dbr}"

Connect-AzAccount -Identity -Subscription "${subscription_id}"

$budgetAmount = (Get-AzConsumptionBudget -name $budget_name).Amount
$currentSpendMain = (Get-AzConsumptionBudget -name $budget_name).currentspend.amount
$currentSpendDbr = 0
try { $currentSpendDbr = (Get-AzConsumptionBudget -name $budget_name_dbr).currentspend.amount } finally { $currentSpendDbr = 0 }

Write-Output "Current spend for budgets: $budget_name and $budget_name_dbr is $currentSpendMain + $currentSpendDbr (trigger is $trigger_percent percent)"
if (($currentSpendMain + $currentSpendDbr ) -ge ($budgetAmount * $trigger_percent / 100)) {
    Write-Output "Disabling CMK in AKV $key_vault_name"

    Update-AzKeyVaultKey -VaultName "$key_vault_name" -Name 'project-cmk' -Enable $false
}

Write-Output "Completed"
