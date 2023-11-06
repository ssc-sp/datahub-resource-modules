
param (
    [Parameter(Position=0)][string]$version
)

$PSScriptRoot
$cwd = Get-Location

Copy-item main.tf-templ sample.tf -Force

$file = 'sample.tf'; (Get-Content $file) -replace '{{version}}', "$version" -replace '{{branch}}', '' | Set-Content $file