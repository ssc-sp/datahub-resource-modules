
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
try { $currentSpendDbr = (Get-AzConsumptionBudget -name $budget_name_dbr).currentspend.amount } catch { $currentSpendDbr = 0 }

$totalSpendDollar = [math]::round(($currentSpendMain + $currentSpendDbr ))
$totalPercent = [math]::round((($currentSpendMain + $currentSpendDbr ) / $budgetAmount) * 100, 2)
$currentSpendMainDollar = [math]::round($currentSpendMain)
$currentSpendDbrDollar = [math]::round($currentSpendDbr)
Write-Output "Current budgets: $budget_name and $budget_name_dbr combined is $budgetAmount (trigger is $trigger_percent percent)"
Write-Output "Current spend: $budget_name and $budget_name_dbr is $currentSpendMainDollar + $currentSpendDbrDollar = $totalSpendDollar (or $totalPercent percent)"

if (($currentSpendMain + $currentSpendDbr ) -ge ($budgetAmount * $trigger_percent / 100)) {
    Write-Output "Disabling CMK in AKV $key_vault_name"

    Update-AzKeyVaultKey -VaultName "$key_vault_name" -Name 'project-cmk' -Enable $false
}

Write-Output "Completed"
