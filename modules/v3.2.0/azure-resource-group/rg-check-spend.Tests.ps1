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

    


    }



}