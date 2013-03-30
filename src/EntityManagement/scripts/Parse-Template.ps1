#=============================================================================
# Project: Baobab
# Author: Tobias Kiertscher
# Name: Parse-Template.ps1
# Description: 
#   Reads a a file system template and aligns the containing aspects and
#   there inheritance with the given aspect set
# Parameter: 
#   - structureTemplatePath: 
#       Path to the file system template
#   - aspectNames:
#       An array with the requested aspect set
#   - processProperties:
#       A hash table with additional informations for the creation process
# Dependencies: 
#   Resolve-Aspects.ps1
#=============================================================================

param (
    [string]$structureTemplatePath,
	$aspectNames = @(),
	$processProperties = @{}
)

Write-Verbose "+++ ParseTemplate.ps1"

$scriptRoot = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent

if (-not $(Test-Path $structureTemplatePath))
{
    throw "Could not find the template:`n`t$structureTemplatePath"
}

$r = @{}

[xml]$r.Template = $(Get-Content $structureTemplatePath)

$r.Aspects = & "$scriptRoot\Resolve-Aspects.ps1" `
    -aspectLibrary $r.Template.Template.AspectLibrary `
    -aspectNames $aspectNames `
    -processProperties $processProperties

$r.AspectNames = New-Object Collections.ArrayList
foreach ($aspect in $r.Aspects)
{
	if (-not $aspect.name) { continue }
	$r.aspectNames.Add($aspect.name) | Out-Null
}

Write-Verbose "--- ParseTemplate.ps1"
return $r
