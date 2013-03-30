#=============================================================================
# Project: Baobab
# Author: Tobias Kiertscher
# Name: New-EntityStructure.ps1
# Description: 
#   Adds actions to the file system structure of an entity.
# Parameter: 
#   - entityRoot: 
#       Path to the root of the entity
#   - structureTemplatePath:
#       Path to the entity template
#   - aspectNames:
#       An array with requested aspects
#       Default value: An empty array
#   - processProperties:
#       A hash table with additional informations for the creation process
# Dependencies: 
#   Parse-Template.ps1
#   Check-Aspect.ps1
#   Add-Action.ps1
#=============================================================================

param(
    [string]$entityRoot,
    [string]$structureTemplatePath,
    $aspectNames = @(),
    $processProperties = @{}
)

Write-Verbose "+++ New-EntityStructure.ps1"

$scriptRoot = [IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)
$entityLocalScripts = "$entityRoot\.entity\scripts"

if (-not $(Test-Path $entityLocalScripts))
{
	mkdir $entityLocalScripts | Out-Null
}
Copy-Item "$scriptRoot\wrapper\EntityToolsLib.ps1" $entityLocalScripts

$parsingResult = & "$scriptRoot\Parse-Template.ps1" `
	$structureTemplatePath $aspectNames $processProperties

$template = $parsingResult.Template
$aspectNames = $parsingResult.AspectNames

$actions = $template.SelectSingleNode("/Template/Actions")
if (-not $actions)
{
	return
}

#if ($actions -is [System.Xml.XmlElement]) {
  foreach ($actionTag in $actions.SelectNodes("Action"))
  {
    if (& "$scriptRoot\Check-Aspect.ps1" $actionTag $aspectNames)
    {
      & "$scriptRoot\Add-Action.ps1" `
        -entityRoot $entityRoot `
        -actionName $actionTag.name
    }
  }
#}

Write-Verbose "--- New-EntityStructure.ps1"
