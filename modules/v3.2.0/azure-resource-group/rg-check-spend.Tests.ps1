# Import the Pester module
Import-Module Pester

# Describe block for the tests
Describe 'Budget Script Tests' {

    # Mock the Azure cmdlets
    Mock -CommandName Connect-AzAccount -MockWith {
        Write-Host "Mock Connect-AzAccount called"
    }

    Mock -CommandName Get-AzConsumptionBudget -MockWith {
        param ($name)
        if ($name -eq "TestBudget") {
            [PSCustomObject]@{ Amount = 1000; currentspend = [PSCustomObject]@{ amount = 500 } }
        } elseif ($name -eq "TestBudgetDbr") {
            [PSCustomObject]@{ Amount = 1000; currentspend = [PSCustomObject]@{ amount = 300 } }
        }
    }

    Mock -CommandName Update-AzKeyVaultKey -MockWith {
        param ($VaultName, $Name, $Enable)
        Write-Host "Mock Update-AzKeyVaultKey called with VaultName: $VaultName, Name: $Name, Enable: $Enable"
    }

    # Test to verify calculations
    It 'Calculates total spend and percentage correctly' {
        # Set parameters
        $params = @{
            trigger_percent = 80
            key_vault_name = "TestKeyVault"
            budget_name = "TestBudget"
            budget_name_dbr = "TestBudgetDbr"
            subscription_id = "TestSubscriptionId"
        }

        # Execute the script
        . "modules/v3.2.0/azure-resource-group/rg-check-spend.ps1" @params

        # Assertions
        $totalSpendDollar | Should -Be 800
        $totalPercent | Should -Be 80
    }

    # Test to verify conditional logic for disabling key
    It 'Disables CMK if total spend exceeds trigger percent' {
        # Set parameters
        $params = @{
            trigger_percent = 70
            key_vault_name = "TestKeyVault"
            budget_name = "TestBudget"
            budget_name_dbr = "TestBudgetDbr"
            subscription_id = "TestSubscriptionId"
        }

        # Execute the script
        . "modules/v3.2.0/azure-resource-group/rg-check-spend.ps1" @params

        # Assertion to check if Update-AzKeyVaultKey was called
        Assert-MockCalled -CommandName Update-AzKeyVaultKey -Exactly 1 -Scope It
    }

    # Test to verify that key is not disabled if total spend does not exceed trigger percent
    It 'Does not disable CMK if total spend does not exceed trigger percent' {
        # Set parameters
        $params = @{
            trigger_percent = 90
            key_vault_name = "TestKeyVault"
            budget_name = "TestBudget"
            budget_name_dbr = "TestBudgetDbr"
            subscription_id = "TestSubscriptionId"
        }

        # Execute the script
        . "modules/v3.2.0/azure-resource-group/rg-check-spend.ps1" @params

        # Assertion to check if Update-AzKeyVaultKey was not called
        Assert-MockCalled -CommandName Update-AzKeyVaultKey -Exactly 0 -Scope It
    }
}