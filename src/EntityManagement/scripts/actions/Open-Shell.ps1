#=============================================================================
# Project: Baobab
# Author: Tobias Kiertscher
# Name: Open-Shell.ps1
# Description: 
#   Shows the shell for the entity
# Parameter: 
#   - entityRoot: 
#       Path to the root of the entity
#       Default value: Current working directory
#=============================================================================

param (
	[string]$entityRoot = $(Get-Location)
)

Write-Verbose "+++ $([IO.Path]::GetFileName($MyInvocation.MyCommand.Definition)) (action)"

$BaobabShell.OpenWindow = $true

Set-Location $entityRoot
${Env:PATH} = "${Env:PATH};$entityRoot\.entity\scripts"

Clear-Host
Write-Host "Entity Management Shell"
Write-Host "-----------------------"
