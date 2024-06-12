# Import the Pester module
Import-Module Pester

# Describe block for the tests
Describe 'Budget Script Tests' {


    BeforeAll {
        # Create a function so the az module doesn't have to be downloaded and installed
        function Connect-AzAccount () {}

        function Get-AzConsumptionBudget {
            param (
                [string]$name
            )
            return [PSCustomObject]@{
                Amount       = 0
                currentspend = [PSCustomObject]@{ amount = 0 }
            }
        }


    
        # Mock the Azure cmdlets
        Mock -CommandName Connect-AzAccount -MockWith {
            Write-Host "Mock Connect-AzAccount called"
        }

        Mock -CommandName Get-AzConsumptionBudget -MockWith {
            param ($name)
            if ($name -eq "TestBudget") {
                return [PSCustomObject]@{ Amount = 1000; currentspend = [PSCustomObject]@{ amount = 500 } }
            } elseif ($name -eq "TestBudgetDbr") {
                return [PSCustomObject]@{ Amount = 1000; currentspend = [PSCustomObject]@{ amount = 300 } }
            }
        }

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


}