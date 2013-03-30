#=============================================================================
# Project: Baobab
# Author: Tobias Kiertscher
# Name: Prepare-Dir.ps1
# Description: 
#   Makes shure the specified directory exists.
#   Returns the resolved absolute path.
# Parameters: 
#   - targetPath: 
#       The (relative) path to a directory
#=============================================================================

param (
	[string]$targetPath
)

if (-not $(Test-Path $targetPath))
{
	$dirInfo = mkdir $targetPath
}

Resolve-Path $targetPath