$PSScriptRoot
$cwd = Get-Location

$allModules = "azure-databricks", "azure-app-service", "azure-postgres", "azure-container-app", "new-project-template", "azure-storage-blob"
$excludeModules = "azure-postgres", "azure-app-service"
$moduleSuffix = ""

foreach ($module in $allModules) {
    write-Host "Checking module $module"
    if (! ($excludeModules -contains $module)) { 
        write-Host "Processing module $module"
        cp $PSScriptRoot/../templates/$module$moduleSuffix/*tf* . -Force

        $file = $module -eq "new-project-template" ? "main.tf" : "$module$moduleSuffix.tf"
        if (Test-Path $file) {
            (Get-Content $file) -replace '^.*modules/', '  source = "../modules/' -replace '{{tag}}', '' | Set-Content $file
        }        
    }    
}

$appservice = "azure-app-service$moduleSuffix.tf"
if (Test-path $appservice) { # Get my IP to whitelist for app service
    (Get-Content $file) -replace 'var.allow_source_ip', 'trimspace("${data.http.myip.response_body}")' | Set-Content $file
}

