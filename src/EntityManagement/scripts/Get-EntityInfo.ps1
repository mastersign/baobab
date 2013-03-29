#=============================================================================
# Project: Baobab
# Author: Tobias Kiertscher
# Name: Get-EntityInfo.ps1
# Description: 
#   Returns the XML DOM of the entity info file if exists; otherwise $null
# Parameter: 
#   - entityRoot: 
#       Root directory of the entity
# Remarks: 
#   The entity info XML file resides in <EntityRoot>\.entity\entity.xml
#=============================================================================

param (
	[string]$entityRoot
)

Write-Verbose "+++ Get-EntityInfo.ps1"

$file = [IO.Path]::Combine($entityRoot, ".entity\entity.xml")
$ret = $null
if (Test-Path $file)
{
	$ret = [xml]$(Get-Content $file)
}

Write-Verbose "--- Get-EntityInfo.ps1"
return $ret