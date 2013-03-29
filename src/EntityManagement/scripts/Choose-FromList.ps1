#=============================================================================
# Project: Baobab
# Author: Tobias Kiertscher
# Name: Choose-FromList.ps1
# Description: 
#   Shows a dialog for selecting one or more elements out of a given list.
# Parameter: 
#   - title: 
#       The title of the dialog.
#       Default value: "Selection"
#   - message:
#       A message text to show in the head of the dialog.
#       Default value: "Select one or more elements in the list and click OK."
#   - list:
#       An array with the elements to choose from
# Dependencies:
#   Load-Assembly.ps1
#   WindowsToolbox.dll
#=============================================================================

param (
	[string]$title = "Selection",
	[string]$message = "Select one or more elements in the list and click OK.",
	[Collections.IEnumerable]$list
)

Write-Verbose "+++ Choose-FromList.ps1"

$scriptRoot = [IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)

& "$scriptRoot\Load-Assembly.ps1" "WindowsToolbox"

[net.kiertscher.toolbox.windows.SelectListDialog]::ShowDialog($title, $message, $list)

Write-Verbose "--- Choose-FromList.ps1"
