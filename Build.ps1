param (
    [string] $target = "default"
)

Import-Module psake
Invoke-psake .\Build.psake.ps1 -taskList $target
