
param (
    [Parameter(Position = 0)][string]$trigger_percent = "${trigger_percent}"
)

$key_vault_name = "${key_vault_name}"
$budget_name = "${budget_name}"
$dbr_rg_name = "${dbr_rg_name}"

Connect-AzAccount -Identity -Subscription "${subscription_id}"

$budget = (Get-AzConsumptionBudget -name $budget_name)
$startDate = $budget.timePeriod.startDate.toUniversalTime()
$endDate = (Get-Date).ToUniversalTime()
$budgetAmount = $budget.Amount
$currentSpendMain = $budget.currentspend.amount

# # Sum the costs for DBR
$dbrUsageDetails = Get-AzConsumptionUsageDetail -StartDate $startDate -EndDate $endDate -ResourceGroup $dbr_rg_name
$currentSpending = $dbrUsageDetails | Measure-Object -Property PretaxCost -Sum

$currentSpendDbr = $currentSpending.Sum
$totalSpendDollar = [math]::round(($currentSpendMain + $currentSpendDbr ))
$totalPercent = [math]::round((($currentSpendMain + $currentSpendDbr ) / $budgetAmount) * 100, 2)
$currentSpendMainDollar = [math]::round($currentSpendMain)
$currentSpendDbrDollar = [math]::round($currentSpendDbr)
Write-Output "Current budgets: $budget_name and $dbrRGName combined is $budgetAmount (trigger is $trigger_percent percent)"
Write-Output "Current spend: $budget_name and $dbrRGName is $currentSpendMainDollar + $currentSpendDbrDollar = $totalSpendDollar (or $totalPercent percent)"

if (($currentSpendMain + $currentSpendDbr ) -ge ($budgetAmount * $trigger_percent / 100)) {
    Write-Output "Disabling CMK in AKV $key_vault_name"

    Update-AzKeyVaultKey -VaultName "$key_vault_name" -Name 'project-cmk' -Enable $false
}

Write-Output "Completed"