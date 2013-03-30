#=============================================================================
# Project: Baobab
# Author: Tobias Kiertscher
# Name: Get-ProfileInfo.ps1
# Description: 
#   Returns the entity profile info file for the current entity profile
#   as XML DOM.
#=============================================================================

Write-Verbose "+++ Get-ProfileInfo.ps1"

$myDir = [IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)
$entityManagement = [IO.Path]::GetDirectoryName($myDir)

Write-Verbose "--- Get-ProfileInfo.ps1"
return [xml]$(Get-Content "$entityManagement\profile.xml")
