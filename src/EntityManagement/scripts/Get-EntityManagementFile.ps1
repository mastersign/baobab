#=============================================================================
# Project: Baobab
# Author: Tobias Kiertscher
# Name: Get-EntityManagementFile.ps1
# Description: 
#   Searches for the entity management file of a given entity profile.
#   Returns $null if no entity management file was found.
#   The search starts at the given start path and propagates upwards
#   in the directory hierarchy through all parent directories.
#   The name of the prospected file is entitymanagement.<profile name>.xml
# Parameter: 
#   - profileName: 
#       The name of entity profile.
#   - startPath:
#       The path to start the search in. Usally the root directory of 
#       an entity.
#       Default value: The current working directory
#=============================================================================

param (
	[string]$profileName,
	[string]$startPath = $(Get-Location)
)

Write-Verbose "+++ Get-EntityManagementFile.ps1"

$emFileName = "entitymanagement.$profileName.xml"
$dirInfo = New-Object System.IO.DirectoryInfo $startPath
$entitymanagementFile = $null
do
{
	$dir = $dirInfo.FullName
	if (Test-Path "$dir\$emFileName")
	{
		$entitymanagementFile = "$dir\$emFileName"
		break
	}
	$dirInfo = $dirInfo.Parent
}
while($dirInfo)

#if (-not $entitymanagementFile)
#{
#	throw New-Object IO.FileNotFoundException -ArgumentList `
#		"Could not find the configuration file '$emFileName'.", `
#		"entitymanagement.xml"
#}

Write-Verbose "--- Get-EntityManagementFile.ps1"
return $entitymanagementFile
