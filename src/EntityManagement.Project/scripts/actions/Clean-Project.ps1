#=============================================================================
# Project: Baobab
# Author: Daniel Kiertscher
# SkriptName: Clean-Project
# Description: 
#   Removes all files and sub folders from $paths, 
#   except: desktop.ini
#   The paths can be relative to the project root.
# Parameter: 
#   - entityRoot:
#       Path to the root of the entity
#       Default value: Current working directory
#   - paths:
#       An array with relative paths to folders
# Remarks:
#   Open files can prohibit the removal of a folder.
#=============================================================================

param (
    [string]$entityRoot = $(Get-Location), 
    $paths
)

Write-Verbose "+++ $([IO.Path]::GetFileName($MyInvocation.MyCommand.Definition)) (action)"

foreach ($path in $paths)
{
	if ([System.IO.Path]::IsPathRooted($path))
	{
		$fullPath = $path
	}
	else
	{
		$fullPath = [System.IO.Path]::Combine($entityRoot, $path)
	}
	if (Test-Path $fullPath)
	{
		Get-childItem $fullPath -Force `
			| Where-Object {$_.Name -ine "desktop.ini"} `
			| Remove-Item -Recurse -Force
	}
}

Write-Verbose "--- $([IO.Path]::GetFileName($MyInvocation.MyCommand.Definition)) (action)"
