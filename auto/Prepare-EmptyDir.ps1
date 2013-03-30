#=============================================================================
# Project: Baobab
# Author: Tobias Kiertscher
# Name: Prepare-Dir.ps1
# Description: 
#   Makes shure the specified directory exists and is empty.
#   Returns the resolved absolute path of the directory.
# Parameters: 
#   - targetPath: 
#       The (relative) path to a directory
#   - exclude:
#       an array with file and folder names which are not allowed to delete
# Dependencies:
#   helper\FileSystemToolbox.dll
#=============================================================================

param (
	[string]$targetPath,
	[String[]]$exclude = @()
)

$myDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent

# Lokales FileSystemToolbox-Assembly für sicheres Reinigen laden
$fileSystemToolboxAssembly = [Reflection.Assembly]::LoadFile("$myDir\helper\FileSystemToolbox.dll")

# Reinigen
if (Test-Path $targetPath)
{
	[net.kiertscher.toolbox.filesystem.DirectoryTools]::Clean($targetPath, $exclude)
	[Threading.Thread]::Sleep(100)
}
else
{
	$dirInfo = mkdir $targetPath
}

Resolve-Path $targetPath