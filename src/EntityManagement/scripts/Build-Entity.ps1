#=============================================================================
# Project: Baobab
# Author: Tobias Kiertscher
# Name: Build-Entity.ps1
# Description: 
#   Constructs the structure for an entity in the given directory.
#   The entity template of the entity management porfile is used to create
#   the folders, icons and actions.
#   At the creation of an entity, a number of different aspects are available.
#   Every aspect controls its own folders, files, and actions.
# Parameter: 
#   - entityRoot: 
#       The root directory of the entity
#       Default value: The current working directory
#   - entityName:
#       The name of the entity, if the name differs from the name of the root
#       directory.
#       Default value: $null
#   - aspectNames:
#       An array mit names of aspects. All given or allready installed aspects 
#       are considered.
#   - promptForAspects:
#       $true, if the GUI for available aspects shell be shown; 
#       otherwise $false$
#       Default value: $false
#   - processProperties:
#       A number of key-value-pairs with informations about the creation
#       process of the entity.
#       Default value: An empty hash table
# Dependencies: 
#   Choose-FromList.ps1
# Remarks: 
#   Repeated call of Build-Entity.ps1 for an existing entity recreates
#   deleted element of the file system structure and updates existing files,
#   if the profile template allowes.
#   A call to Build-Entity.ps1 without any additional aspects represents
#   a repair of the entity.
#=============================================================================

param (
    [string]$entityRoot = $(Get-Location),
    [string]$entityName = $null,
    $aspectNames = @(),
	  [switch]$promptForAspects = $false,
    $processProperties = @{}
)

Write-Verbose "+++ Build-Entity.ps1"

# determine the path of the script
$scriptRoot = [IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)

# Check if the root path of the entity exists
if (-not $(Test-Path $entityRoot))
{
    throw "The target directory does not exist:`n`t$entityRoot"
}
$entityRoot = Resolve-Path $entityRoot

# determine the name of the entity
if (-not $entityName)
{
    $entityName = [IO.Path]::GetFileName($entityRoot)
}

# load the profile info file to get the name of the profile Profils auslesen
$profileInfo = & "$scriptRoot\Get-ProfileInfo.ps1"
$profileName = $profileInfo.Profile.Name
if (-not $profileName)
{
	throw "The profile info file profile.xml does not contain a name tag."
}
$profileName = $profileName.Trim()

# fill $processProperties with base infos of the entity creation
$processProperties.EntityName = $entityName
$processProperties.EntityRoot = $entityRoot
$processProperties.ProfileName = $profileName

# build path to the profile template
$entityTemplatePath = Resolve-Path "$scriptRoot\..\templates\entitytemplate.xml"

### process aspects

if ($promptForAspects)
{
	# gather all available aspects
	[xml]$template = Get-Content $entityTemplatePath
	$aspectTags = $template.SelectNodes("//AspectLibrary/Aspect")
	$aspects = New-Object Collections.ArrayList
	foreach ($at in $aspectTags)
	{
		$aspects.Add($at.name) | Out-Null
	}
	
	# show selection UI
	$aspectNames = & "$scriptRoot\Choose-FromList.ps1" `
		-title "Aspekte auswählen..." `
		-message "Wählen Sie ein oder mehrere Aspekte für die Entity aus." `
		-list $aspects
}


# complete aspect list with allready installed aspects
$entityInfo = & "$scriptRoot\Get-EntityInfo.ps1" -entityRoot $entityRoot
$preExistingAspects = New-Object Collections.ArrayList
if ($entityInfo)
{
	$aspectList = New-Object Collections.ArrayList
	foreach ($an in $aspectNames)
	{
		$aspectList.Add($an) | Out-Null
	}
	$aspects = $entityInfo.Entity.Aspects.Aspect
	foreach ($a in $aspects)
	{
		if (-not $aspectList.Contains($a))
		{
			$aspectList.Add($a) | Out-Null
		}
		if (-not $preExistingAspects.Contains($a))
		{
			$preExistingAspects.Add($a)
		}
	}
	$aspectNames = $aspectList.ToArray()
}

### check aspect compatibility

$validAspects = New-Object Collections.ArrayList
foreach ($a in $aspectNames)
{
	if ($preExistingAspects.Contains($a)) 
	{
		$validAspects.Add($a) | Out-Null
		continue 
	}
	$checkScript = [IO.Path]::Combine($scriptRoot, "aspecthooks\Check-$a.ps1")
	if (Test-Path $checkScript)
	{
		$result = & $checkScript `
			-entityRoot $entityRoot `
			-aspectName $a `
			-processProperties $processProperties
		if ($result -eq "OK")
		{
			$validAspects.Add($a) | Out-Null
		}
		elseif ($result -eq "CANCEL")
		{
			Write-Verbose "User abortion on invalid aspect"
			Write-Verbose "--- Build-Entity.ps1"
			return
		}
	}
	else 
	{
		$validAspects.Add($a) | Out-Null
	}
}
$aspectNames = $validAspects.ToArray()

### create entity structure

# create file system structure of the entity
& "$scriptRoot\New-FileSystemStructure.ps1" `
    -targetDir $entityRoot `
    -structureTemplatePath "$entityTemplatePath" `
    -aspectNames $aspectNames `
    -withInfo $withInfo `
    -processProperties $processProperties

# add additional elements like actions
& "$scriptRoot\New-EntityStructure.ps1" `
	-entityRoot $entityRoot `
	-structureTemplatePath "$entityTemplatePath" `
    -aspectNames $aspectNames `
    -withInfo $withInfo `
    -processProperties $processProperties

### execute aspect trigger

foreach ($a in $aspectNames)
{
	$triggerScript = [IO.Path]::Combine($scriptRoot, "aspecthooks\On-$a.ps1")
	if (Test-Path $triggerScript)
	{
		& $triggerScript `
			-entityRoot $entityRoot `
			-aspectName $a `
			-firstApplication $(-not $preExistingAspects.Contains($a)) `
			-processProperties $processProperties
	}
}


Write-Verbose "--- Build-Entity.ps1"
