BeforeAll {
    . "$PSScriptRoot\rg-check-spend.ps1"
    Write-Host "rg-check-spend.ps1 loaded"

    # Create a mock Connect-AzAccount function
    function Connect-AzAccount {
        param (
            [switch]$Identity,
            [string]$Subscription
        )
        if ($Identity.IsPresent) {
            if ($Subscription -eq "fail-subscription-id") {
                throw "Mock Connect-AzAccount failed to connect with Subscription: $Subscription"
            }
            Write-Host "Mock Connect-AzAccount called with -Identity flag set and Subscription: $Subscription"
        } else {
            if ($Subscription -eq "fail-subscription-id") {
                throw "Mock Connect-AzAccount failed to connect with Subscription: $Subscription"
            }
            Write-Host "Mock Connect-AzAccount called with Subscription: $Subscription"
        }
    }
    # Create a mock Get-AzConsumptionBudget function
    function Get-AzConsumptionBudget {
        param (
            [string]$Name
        )
        if ($Name -eq "existing-budget") {
            return @{Name = $Name; Amount = 1000}
        } else {
            throw "Budget not found."
        }
    }
}



Describe "Connect-ToAzureIdentity" {
    It "should call Connect-AzAccount with the subscription ID if provided" {
        $subscriptionId = "test-subscription-id"
        $result = Connect-ToAzureIdentity -SubscriptionId $subscriptionId

        $result | Should -Be $true
    }

    It "should call Connect-AzAccount without a subscription ID if not provided" {
        $result = Connect-ToAzureIdentity

        $result | Should -Be $true
    }

    It "should return $true and output a success message on successful connection with subscription ID" {
        $subscriptionId = "test-subscription-id"
        $result = Connect-ToAzureIdentity -SubscriptionId $subscriptionId

        $result | Should -Be $true
    }

    It "should return $true and output a success message on successful connection without subscription ID" {
        $result = Connect-ToAzureIdentity

        $result | Should -Be $true
    }

    It "should return $false and output an error message if Connect-AzAccount fails" {
        $subscriptionId = "fail-subscription-id"
        $result = Connect-ToAzureIdentity -SubscriptionId $subscriptionId
        $result | Should -Be $false
    }
}
