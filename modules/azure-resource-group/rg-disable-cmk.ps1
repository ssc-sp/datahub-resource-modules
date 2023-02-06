
param (
    [string]$u,
    [string]$p,
    [Parameter(Position=0)][string]$rgName
)

Write-Host "Disabling CMK in resource group " $rgName
