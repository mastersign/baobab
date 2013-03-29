#=============================================================================
# Project: Baobab
# Author: Tobias Kiertscher
# Name: Choose-Directory.ps1
# Description: 
#   Shows a dialog for choosing a directory.
# Parameter: 
#   - description: 
#       A description text to show in the head of the dialog.
#       Default value: "Choose a folder."
#   - rootDir:
#       The root directory of the folder tree.
#       Supported are strings for paths and elements of the
#       enumeration [Environment+SpecialFolder].
#       Default value: [Environment+SpecialFolder]::Desktop
#=============================================================================

param (
	[string]$description = "Wählen Sie ein Verzeichnis.",
	$rootDir = [Environment+SpecialFolder]::Desktop
)

Write-Verbose "+++ Choose-Directory.ps1"

$app = new-object -com Shell.Application
$folder = $app.BrowseForFolder(0, $description, 0, $rootDir)
return [string]$folder

Write-Verbose "--- Choose-Directory.ps1"
