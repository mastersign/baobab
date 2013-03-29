#=============================================================================
# Project: Baobab
# Author: Tobias Kiertscher
# Name: Choose-SaveFile.ps1
# Description: 
#   Shows a save file dialog.
# Parameter: 
#   - title: 
#       The title of the dialog.
#       Default value: "Select file..."
#   - filter:
#       A file filter to reduce the number of visible files.
#       The filter must be a string with the following pattern:
#         "<caption>|<pattern1>;<pattern2>"
#       Example: "Pictures (*.jpg, *.png, *.gif)|*.jpg;*.png;*.gif"
#       Default: "All files (*.*)|*.*"
#   - overridePrompt:
#       $true if a prompt shell be shown, if an existing file is selected;
#       otherwise $false.
#   - initFileName:
#       A proposal for a possible file name
#       Default value: ""
#   - initDir:
#       The folder wich is initially shown in the dialog.
#       Default value: $HOME
# Dependencies:
#   Load-Assembly.ps1
#   System.Windows.Forms
#=============================================================================

param (
	[string]$title = "Select file...",
	[string]$filter = "All files (*.*)|*.*",
	[string]$overwritePrompt = $true,
	[string]$initFileName = "",
	[string]$initDir = $HOME
)

Write-Verbose "+++ Choose-SaveFile.ps1"

[Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
#[Reflection.Assembly]::LoadWithPartialName("PresentationFramework") | Out-Null

$dlg = New-Object System.Windows.Forms.SaveFileDialog
#$dlg = New-Object Microsoft.Win32.SaveFileDialog
$dlg.Title = $title
$dlg.Filter = $filter
$dlg.OverwritePrompt = $overwritePrompt
$dlg.InitialDirectory = $initDir
$dlg.FileName = $initFileName
$dlg.ShowHelp = $true

$res = $dlg.ShowDialog()

if ($res -eq "OK")
{
	return $dlg.FileName
}
else
{
	return $null
}

Write-Verbose "--- Choose-SaveFile.ps1"
