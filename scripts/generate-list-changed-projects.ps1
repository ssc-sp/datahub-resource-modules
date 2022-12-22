$project_list = @()
foreach ($file in (git diff --name-only "HEAD~1")) {
    $file_path = @($file -split "/")
    if ($file_path[0] -eq "terraform" -AND $file_path[1] -eq "projects" -AND $file_path[2] -ne "") {
        write-host "FSDH: Detected change in project: " $file_path[2]
        $project_list += $file_path[2]
    }
}

$project_list_csv = (($project_list | Get-Unique) -join ",")
Write-Host "SSC_CHANGED_PROJECTS=" $project_list_csv
Write-Host "##vso[task.setvariable variable=SSC_CHANGED_PROJECTS;]$project_list_csv"