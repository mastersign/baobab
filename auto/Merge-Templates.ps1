#=============================================================================
# Project: Baobab
# Author: Tobias Kiertscher
# Name: Merge-Templates.ps1
# Description: 
#   Merges the base entity template with the profile entity template.
# Parameters: 
#   - baseTemplateFile: 
#       The base entity template file
#   - profileTemplateFile:
#       The profile entity template file
#   - targetFile:
#       The target file
#=============================================================================

param (
	[string]$baseTemplateFile,
	[string]$profileTemplateFile,
	[string]$targetFile
)

# load templates
[xml]$baseDoc = Get-Content $baseTemplateFile
[xml]$profileDoc = Get-Content $profileTemplateFile

### sync aspects
# Remarks: The DOM of the base entity template is only read
#          The DOM of the profile entity tempalte is extended by missing elements

# select aspect library from the profile entity template
$profileAspectLib = $profileDoc.Template.AspectLibrary
# select aspects of the base entity template
$baseAspects = $baseDoc.Template.AspectLibrary.Aspect

if (-not $profileAspectLib)
{
	# take over the aspect library of the base entity template in case 
	# the profile entity template has none
	$baseAspectLibTag = $baseDoc.SelectSingleNode("/Template/AspectLibrary")
	$profileAspectLib = $profileDoc.ImportNode($baseAspectLibTag, $true)
	$profileDoc.Template.PrependChild($profileAspectLib) | Out-Null
}
elseif ($baseAspects) 
{
	# add aspects from the base entity template to the profile entity template
	# if they do not exist allready
	foreach ($bA in $baseAspects)
	{
		$found = $false
		$pA = $profileAspectLib.SelectSingleNode("Aspect[@name='$($bA.name)']")
		if (-not $pA)
		{
			$newPA = $profileDoc.ImportNode($bA, $true)
			$profileAspectLib.PrependChild($newPA) | Out-Null
		}
	}
}

### sync the file systemstructure

# select file system structure of the profile entity template
$profileStructure = $profileDoc.Template.Structure
# select file system structure of the base entity template
$baseStructure = $baseDoc.Template.Structure

# check preconditions
if (-not $profileStructure)
{
	throw "The profile entity template must have a Structure tag."
}
if (-not $baseStructure)
{
	throw "The base entity template must have a structure tag."
}

# This function merges the file system templates recursively.
# Elements of the profile entity template have priority
# Parameters:
#   - profileDir: 
#       The XML element representing the directory to sync from the profile
#       entity template
#   - baseDir:
#       The XML element representing the directory to sync from the base
#       entity template
function MergeDirectories([System.Xml.XmlElement]$profileDir, [System.Xml.XmlElement]$baseDir)
{
	# list all subdirectories of the current directory in the base entity template
	$baseSubDirs = $baseDir.Dir
	if ($baseSubDirs) 
	{
		# iterate over subdirectories
		foreach ($bSD in $baseSubDirs)
		{
			$pSD = $profileDir.SelectSingleNode("Dir[@name='$($bSD.name)']")
			if (-not $pSD)
			{
				# Add the directory if not existing in profile entity template
				$newPSD = $profileDoc.ImportNode($bSD, $true)
				$profileDir.AppendChild($newPSD) | Out-Null
			}
			else
			{
				# Merge if it exists
				MergeDirectories $pSD $bSD
			}
		}
	}
	
	# List all files of the current directory in the base entity template
	$baseFiles = $baseDir.File
	if ($baseFiles)
	{
		# iterate over files
		foreach ($bF in $baseFiles)
		{
			$pF = $profileDir.SelectSingleNode("File[@name='$($bF.name)']")
			if (-not $pF)
			{
				# Add the file if not existing in profile entity template
				$newPF = $profileDoc.ImportNode($bF, $true)
				$profileDir.AppendChild($newPF) | Out-Null
			}
		}
	}
}

# Merge root directories of profile and base entity template
MergeDirectories $profileStructure $baseStructure

### sync actions

# select action library of the profile entity template
$profileActionLib = $profileDoc.Template.Actions
# select action library of the base entity template
$baseActions = $baseDoc.Template.Actions.Action

if (-not $profileActionLib)
{
	# take over the action library of the base entity template in case 
	# the profile entity template has none
	$baseActionsTag = $baseDoc.SelectSingleNode("/Template/Actions")
	$profileActionLib = $profileDoc.ImportNode($baseActionsTag, $true)
	$profileDoc.Template.AppendChild($profileActionLib) | Out-Null
}
elseif ($baseActions)
{
	# iterate over actions
	foreach ($bA in $baseActions)
	{
		$found = $false
		$pA = $profileActionLib.SelectSingleNode("Action[@name='$($bA.name)']")
		if (-not $pA)
		{
			# Add the action if not existing in profile entity template
			$newPA = $profileDoc.ImportNode($bA, $true)
			$profileActionLib.PrependChild($newPA) | Out-Null
		}
	}
}

### write merged XML to the target file

$xmlWriterSettings = New-Object System.Xml.XmlWriterSettings
$xmlWriterSettings.Indent = $true
$xmlWriter = [System.Xml.XmlWriter]::Create($targetFile, $xmlWriterSettings)
$profileDoc.Save($xmlWriter)
$xmlWriter.Close()
