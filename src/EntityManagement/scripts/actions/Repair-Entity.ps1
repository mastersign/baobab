#=============================================================================
# Project: Baobab
# Author: Tobias Kiertscher
# Name: Repair-Entity.ps1
# Description: 
#   Repairs an entity by reapplying all installed aspects of the entity.
#   Changed files are not replaced, only missing restored.
# Parameter: 
#   - entityRoot:
#       Path to the root of the entity
#       Default value: Current working directory
#   - processProperties:
#       A hash table with additional information for creation process
# Dependencies: 
#   Get-EntityInfo.ps1
#   New-FileSystemStructure.ps1
#   New-EntityStructure.ps1
#=============================================================================

param (
    [string]$entityRoot = $(Get-Location),
	$processProperties = @{}
)

Write-Verbose "+++ $([IO.Path]::GetFileName($MyInvocation.MyCommand.Definition)) (action)"

$myDir = [IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)
$scriptRoot = [IO.Path]::GetDirectoryName($myDir)

$entityRoot = [IO.Path]::GetFullPath($entityRoot)
if (-not $(Test-Path $entityRoot))
{
    throw "Could not find the target directory for the entity:`n`t$entityRoot"
}

$entityInfo = & "$scriptRoot\Get-EntityInfo.ps1" $entityRoot

if ($entityInfo.Entity.Name)
{
	$entityName = $entityInfo.Entity.Name.Trim()
}
else
{
	$entityName = [IO.Path]::GetFileName($entityRoot)
}

$processProperties.EntityName = $entityName
$processProperties.EntityRoot = $entityRoot

# Repair-Entity.exe immer erneuern
$repairRunner = [IO.Path]::Combine($entityRoot, "Repair-Entity.exe")
if (Test-Path $repairRunner) { Remove-Item $repairRunner }

$entityTemplatePath = Resolve-Path "$scriptRoot\..\templates\entitytemplate.xml"

$aspectListTag = $entityInfo.Entity.SelectSingleNode("Aspects")
$aspectTags = $aspectListTag.SelectNodes("Aspect")
$aspectNames = New-Object Collections.ArrayList
foreach ($at in $aspectTags)
{
	$aspectNames.Add($at.InnerText) | Out-Null
}

& "$scriptRoot\New-FileSystemStructure.ps1" `
    -targetDir "$entityRoot" `
    -structureTemplatePath "$entityTemplatePath" `
    -aspectNames $aspectNames `
    -withInfo $withInfo `
    -processProperties $processProperties

& "$scriptRoot\New-EntityStructure.ps1" `
	-entityRoot "$entityRoot" `
	-structureTemplatePath "$entityTemplatePath" `
    -aspectNames $aspectNames `
    -withInfo $withInfo `
    -processProperties $processProperties

Write-Verbose "--- $([IO.Path]::GetFileName($MyInvocation.MyCommand.Definition)) (action)"
