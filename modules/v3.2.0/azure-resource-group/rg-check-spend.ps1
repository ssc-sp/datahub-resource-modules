#Install-Module -Name Az.Accounts -RequiredVersion 2.19.0 
Import-Module -Name Az.Accounts -RequiredVersion 2.19.0 

#Install-Module -Name Az.KeyVault -RequiredVersion 5.3.0 
Import-Module -Name Az.KeyVault -RequiredVersion 5.3.0 

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
        if (Get-AzContext) {
            Write-Output "Already connected to Azure subscription $SubscriptionId."
        } elseif ($SubscriptionId) {
            Connect-AzAccount -Identity -Subscription $SubscriptionId
            Write-Output "Successfully connected to Azure subscription $SubscriptionId."
        } else {
            Connect-AzAccount -Identity
            Write-Output "Successfully connected to Azure with the default subscription."
        }
        # workaround https://github.com/Azure/azure-powershell/issues/24942
        #Set-AzConfig -EnableLoginByWam $true

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
        Write-Error "Failed to retrieve the budget."
        Write-Error $_.Exception.Message
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
        Write-Error $_.Exception.Message
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
        return $true
    } catch {
        Write-Error $_.Exception.Message
        return $false
    }
}

# Connect to Azure
if (Connect-ToAzureIdentity -SubscriptionId $subscription_id) {
    Write-Output "Connection to Azure successful"
} else {
    Write-Error "Failed to connect to Azure. Exiting script."
    exit 1
}

# Check if CMK exists and is already disabled
$keyStatus = Get-VaultKeyStatus -vaultName $key_vault_name -keyName $key_name

if ($null -eq $keyStatus) {
    Write-Error "Issue getting key, please investigate"
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

$totalBudget = [math]::round($totalBudget, 2)
$totalSpent = [math]::round($totalSpent, 2)

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
Write-Output "Trigger Percent: $trigger_percent"

# Check if the total spend percentage has reached or exceeded the trigger percentage
if ($totalPercent -ge $trigger_percent) {
    Write-Output "Current percentage exceeds the trigger percent. Disabling CMK in AKV $key_vault_name."
    
    if (Set-VaultKeyStatus -vaultName $key_vault_name -keyName $key_name -enabled $false) {
        Write-Output "Successfully updated the status of the key '$keyName' in vault '$vaultName'."
        exit 0
    } else {
        Write-Error "Failed to update the status of the key '$keyName' in vault '$vaultName'."
        exit 1
    }

} else {
    Write-Output "Current spend does not exceed the trigger percent. No action needed."
}
