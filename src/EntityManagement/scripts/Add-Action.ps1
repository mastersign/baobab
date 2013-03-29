#=============================================================================
# Project: Baobab
# Author: Tobias Kiertscher
# Name: Add-Action.ps1
# Description: 
#   Adds an action to an entity. 
#   Wrapper and runner are copied to the respective directories.
# Parameter: 
#   - entityRoot: 
#       Path to the root of the entity.
#   - actionName:
#       The name of the action.
# Remarks:
#   Existing files are not replaced.
#=============================================================================

param (
	[string]$entityRoot,
	[string]$actionName
)

Write-Verbose "+++ Add-Action.ps1"

# Pfade ermitteln
$scriptRoot = [IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)
$wrapperSrc = Resolve-Path "$scriptRoot\wrapper"
$runnerSrc = "$scriptRoot\..\runner"

$wrapperScript = "$wrapperSrc\$actionName.ps1"
$runnerName = "$actionName.exe"

# Check if the template for the wrapper script exists in the entity management system
if (Test-Path $wrapperScript)
{
	if (-not $(Test-Path $([IO.Path]::Combine("$entityRoot", ".entity\scripts\$actionName.ps1"))))
	{
		# Check if the wrapper script exists in the entity, copy if not
		Copy-Item $wrapperScript "$entityRoot\.entity\scripts"
	}
}
else
{
	Write-Warning "Could not find the wrapper script for action '$actionName'.`n`t$wrapperScript"
	Write-Verbose "--- Add-Action.ps1"
	return
}

# Check if template of runner exists in the entity management system
if (Test-Path "$runnerSrc\$runnerName")
{
	if (-not $(Test-Path "$entityRoot\$runnerName"))
	{
		# Check if the runner exists in the entity, copy if not
		Copy-Item "$runnerSrc\$runnerName" $entityRoot
	}
}
else
{
	Write-Warning "Could not find the runner of the action '$actionName'."
	Write-Verbose "--- Add-Action.ps1"
	return
}

Write-Verbose "--- Add-Action.ps1"
