#=============================================================================
# Project: Baobab
# Author: Daniel Kiertscher, Tobias Kiertscher
# SkriptName: EntityToolsLib.ps1
# Description: 
#   Creates a number of functions and variables, available direct inside 
#   of an entity
# Precondition: 
#   This function library must reside in the script directory of the entity
#=============================================================================

Write-Verbose "+++ EntityToolsLib.ps1"

# local script directory of the entity
$entityLocalScripts = [IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)

# path to the root of the entity
$entityRoot = Resolve-Path "$entityLocalScripts\..\.."

$entityInfoFile = Resolve-Path "$entityRoot\.entity\entity.xml"
[xml]$entityInfo = Get-Content $entityInfoFile
$entityProfile = $entityInfo.Entity.Profile

#-----------------------------------------------------------------------------
# Description: 
#   Determines the first entity entity management configuration file 
#   (entitymanagement.<profile>.xml) in the path upwards and returns 
#   its contents as DOM
# Parameter:
#   -startPath:
#     The start path to search for the entity management configuration
#     Default value: The parent directory of this script file
# Exceptions:
#   Throws a FileNotFoundException, if the entity management configuration 
#   could not be found.
#-----------------------------------------------------------------------------
function Get-EntityManagementFile
{
	param ([string]$startPath = $entityLocalScripts)
	
	$emFileName = "entitymanagement.$entityProfile.xml"
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
	
	if (-not $entitymanagementFile)
	{
		throw New-Object IO.FileNotFoundException -ArgumentList `
			"Could not find the entity management configurationfile '$emFileName'.", `
			$emFileName
	}
	
	return $entitymanagementFile
}

#-----------------------------------------------------------------------------
# Name: Get-EntityManagementRootPath
# Description: 
#   Determines the root path of the entity management system for the entity
#   profile from the first found entity management configuration file
#-----------------------------------------------------------------------------
function Get-EntityManagementRootPath
{
	$entitymanagementFile = Get-EntityManagementFile
	[xml]$emContent = Get-Content $entitymanagementFile
	
	$management = $emContent.EntityManagement.RootPath
	if ($management)
	{
		$management = $management.Trim()
	}
	else
	{
		throw "Could not find a RootPath tag in the entity management configuration file:`n`t$entitymanagementFile"
	}
	
	if (-not [IO.Path]::IsPathRooted($management))
	{
		$management = [IO.Path]::Combine([IO.Path]::GetDirectoryName($entitymanagementFile), $management)
	}
	
	if (-not $(Test-Path $management))
	{
		throw "The found path in the entity management configuration file is invalid:`n`tFile: $entitymanagementFile`n`tPath: $management"
	}
	return Resolve-Path $management
}

#-----------------------------------------------------------------------------
# Name: Get-ActionName
# Description: 
#   Determines the name of the action from the file name of a given script
# Parameter:
#   - scriptFile:
#       Name or path to an action script
#-----------------------------------------------------------------------------
function Get-ActionName
{
	param ([string]$scriptFile)
	
	return 	[IO.Path]::GetFileNameWithoutExtension($scriptFile)
}

#-----------------------------------------------------------------------------
# Initialization
#-----------------------------------------------------------------------------

# In the following, some variables and paths are registered

# Remarks:
#   To have the variables and functions created in this library available
#   in the calling script, the .-operator must be used to load this libary
#   . "$entityLocalScripts\EntityToolsLib.ps1"

# The root path to the entity management system
$entityManagement = Get-EntityManagementRootPath

# The script directory of the entity management system
$entityScripts = [IO.Path]::Combine($entityManagement, "scripts")

# The action directory of the entity management system
$entityActions = [IO.Path]::Combine($entityScripts, "actions")

Write-Verbose "--- EntityToolsLib.ps1"
