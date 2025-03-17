# Input bindings are passed in via param block.
param($Timer)

# Get the current universal time in the default string format
$currentUTCtime = (Get-Date).ToUniversalTime()

# Write an information log with the current time.
Write-Host "FSDH - func-test PowerShell timer trigger function ran! TIME: $currentUTCtime"
Write-Output 'Getting PowerShell Module'

$result = Get-Module -ListAvailable |

Select-Object Name, Version, ModuleBase |

Sort-Object -Property Name |

Format-Table -wrap |

Out-String

Write-output `n$result

Get-PSRepository