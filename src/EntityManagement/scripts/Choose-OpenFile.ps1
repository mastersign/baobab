#=============================================================================
# Project: Baobab
# Author: Tobias Kiertscher
# Name: Choose-OpenFile.ps1
# Description: 
#   Shows an open file dialog .
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
	[string]$initDir = $HOME
)

Write-Verbose "+++ Choose-OpenFile.ps1"

[Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
#[Reflection.Assembly]::LoadWithPartialName("PresentationFramework") | Out-Null

$dlg = New-Object System.Windows.Forms.OpenFileDialog
#$dlg = New-Object Microsoft.Win32.OpenFileDialog
$dlg.Title = $title
$dlg.Filter = $filter
$dlg.InitialDirectory = $initDir
$dlg.ShowHelp = $true

$res = $dlg.ShowDialog()

if ($res -eq "OK")
{
	Write-Verbose "--- Choose-OpenFile.ps1"
	return $dlg.FileName
}
else
{
	Write-Verbose "--- Choose-OpenFile.ps1"
	return $null
}
