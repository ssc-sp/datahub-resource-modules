param (
    [Parameter(Mandatory=$true)][string]$key_vault_name,
    [Parameter(Mandatory=$true)][string[]]$budget_names,
    [string]$trigger_percent = 100,
    [string]$key_name = "project-cmk",
    [string]$subscription_id
)

function Connect-ToAzureIdentity {
    param (
        [string]$SubscriptionId
    )

    try {
        $currentContext = Get-AzContext
        if ($currentContext -and $currentContext.Subscription.Id -eq $SubscriptionId) {
            Write-Output "Already connected to Azure subscription $SubscriptionId."
            return $true
        } elseif ($SubscriptionId) {
            Connect-AzAccount -Identity -Subscription $SubscriptionId
            Write-Output "Successfully connected to Azure subscription $SubscriptionId."
        } else {
            Connect-AzAccount -Identity
            Write-Output "Successfully connected to Azure with the default subscription."
        }
        return $true
    }
    catch {
        Write-Error "Failed to connect to Azure. Error: $_"
        return $false
    }
}

function Get-AzureBudget {
    param (
        [string]$BudgetName
    )

    try {
        $budget = Get-AzConsumptionBudget -Name $BudgetName
        return $budget
    }
    catch {
        Write-Error "Failed to retrieve the budget. Error: $_"
        return $null
    }
}

function Get-VaultKeyStatus {
    param (
        [string]$vaultName,
        [string]$keyName
    )
    try {
        $key = Get-AzKeyVaultKey -VaultName $vaultName -Name $keyName
        return $key.Attributes.Enabled # Accessing the Enabled property correctly
    } catch {
        Write-Error "Failed to retrieve the status of the key '$keyName' in vault '$vaultName'."
        return $null
    }
}

function Set-VaultKeyStatus {
    param (
        [string]$vaultName,
        [string]$keyName,
        [boolean]$enabled
    )
    try {
        Update-AzKeyVaultKey -VaultName $vaultName -Name $keyName -Enable $enabled -ErrorAction Stop
        Write-Output "Successfully updated the status of the key '$keyName' in vault '$vaultName'."
    } catch {
        Write-Error "Failed to update the status of the key '$keyName' in vault '$vaultName'."
        Write-Error $_.Exception.Message
        exit 1
    }
}

# Connect to Azure
if (Connect-ToAzureIdentity -SubscriptionId $subscription_id) {
    Write-Output "Connection successful"
} else {
    Write-Error "Failed to connect to Azure. Exiting script."
    exit 1
}

# Check if CMK is already disabled
$keyStatus = Get-VaultKeyStatus -vaultName $key_vault_name -keyName $key_name
if ($null -eq $keyStatus) {
    Write-Error "Failed to retrieve the status of the key '$key_name' in vault '$key_vault_name'. Exiting script."
    exit 1
}

if (-not $keyStatus) {
    Write-Output "$key_name key was disabled in a previous run"
    exit 0
}

# Initialize total budget and spent values
$totalBudget = 0
$totalSpent = 0

foreach ($budget in $budget_names) {
    $currentBudget = Get-AzureBudget -BudgetName $budget
    if ($currentBudget) {
        $totalBudget += $currentBudget.Amount
        $totalSpent += $currentBudget.CurrentSpend.Amount
    } else {
        Write-Error "Budget $budget not found or failed to retrieve."
    }
}

#round to dollars and cents
$totalSpent = [math]::round($totalSpent, 2)
$totalBudget = [math]::round($totalBudget, 2)

Write-Output "Total Budget: $totalBudget"
Write-Output "Total Spent: $totalSpent"

# Calculate percentage with zero and negative check
if ($totalBudget -le 0) {
    Write-Error "Total budget amount is zero or negative. Cannot calculate percentage."
    $totalPercent = 0  
} else {
    $totalPercent = [math]::round((($totalSpent) / $totalBudget) * 100)
}

Write-Output "Total Percent: $totalPercent"

# Check if the total spend percentage has reached or exceeded the trigger percentage
if ($totalPercent -ge $trigger_percent) {
    Write-Output "Current percentage exceeds the trigger percent. Disabling CMK in AKV $key_vault_name."
    Set-VaultKeyStatus -vaultName $key_vault_name -keyName $key_name -enabled $false
} else {
    Write-Output "Current spend does not exceed the trigger percent. No action needed."
}
