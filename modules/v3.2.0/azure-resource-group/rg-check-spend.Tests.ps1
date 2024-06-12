# Import the Pester module
Import-Module Pester

# Describe block for the tests
Describe 'Budget Script Tests' {

    BeforeAll {
        # Create az functions so the az modules don't have to be downloaded and installed
        function Connect-AzAccount {
            param (
                [switch]$Identity,
                [string]$Subscription
            )
            if ($Identity.IsPresent) {
                Write-Host "Mock Connect-AzAccount called with -Identity flag set and Subscription: $Subscription"
            } else {
                Write-Host "Mock Connect-AzAccount called with Subscription: $Subscription"
            }
        }

        function Get-AzConsumptionBudget {
            param (
                [string]$name
            )
            return [PSCustomObject]@{
                Amount       = 0
                currentspend = [PSCustomObject]@{ amount = 0 }
            }
        }

        function Update-AzKeyVaultKey {
            param (
                [string]$VaultName,
                [string]$Name,
                [bool]$Enable
            )
            Write-Host "Mock Update-AzKeyVaultKey called with VaultName: $VaultName, Name: $Name, Enable: $Enable"
        }

        # Mock the Azure cmdlets
        Mock -CommandName Connect-AzAccount -MockWith {
            param ($Identity, $Subscription)
            if ($Identity.IsPresent) {
                Write-Host "Mock Connect-AzAccount called with -Identity flag set and Subscription: $Subscription"
            } else {
                Write-Host "Mock Connect-AzAccount called with Subscription: $Subscription"
            }
        }

        Mock -CommandName Get-AzConsumptionBudget -MockWith {
            param ($name)
            switch ($name) {
                "TestBudget" { return [PSCustomObject]@{ Amount = 1000; currentspend = [PSCustomObject]@{ amount = 500 }}}
                "emptyBudget" { return [PSCustomObject]@{ Amount = 0; currentspend = [PSCustomObject]@{ amount = 0 }}}
                "TestBudgetDbr" { return [PSCustomObject]@{ Amount = 1000; currentspend = [PSCustomObject]@{ amount = 300 }}}
                default { return [PSCustomObject]@{ Amount = 0; currentspend = [PSCustomObject]@{ amount = 0 }}}
            }
        }

        Mock -CommandName Update-AzKeyVaultKey -MockWith {
            param ($VaultName, $Name, $Enable)
            Write-Host "Mock Update-AzKeyVaultKey called with VaultName: $VaultName, Name: $Name, Enable: $Enable"
        }
    }

    # Test to verify budget retrieval 
    It 'Successful capture of  total spend and percentage correctly' {
        # Set parameters
        $params = @{
            trigger_percent = 80
            budget_name = "TestBudget"
            budget_name_dbr = "TestBudgetDbr"
        }

        # Execute the script
        $output = . "modules/v3.2.0/azure-resource-group/rg-check-spend.ps1" @params

        # Assertions
        $currentSpendMainDollar | Should -Be 500
        $currentSpendDbrDollar | Should -Be 300
}