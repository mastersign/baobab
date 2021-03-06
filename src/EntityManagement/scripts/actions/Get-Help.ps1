#=============================================================================
# Project: Baobab
# Author: Tobias Kiertscher
# Name: Get-Help.ps1
# Description: 
#   Shows a profile template in the browser. A XSLT file could make the
#   XML file of the template mor readable.
# Parameter: 
#   - entityRoot: 
#       Path to the root of the entity
#       Default value: Current working directory
#=============================================================================

param (
    [string]$entityRoot = $(Get-Location)
)

Write-Verbose "+++ $([IO.Path]::GetFileName($MyInvocation.MyCommand.Definition)) (action)"

$myDir = [IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)
$scriptRoot = [IO.Path]::GetDirectoryName($myDir)

$entityRoot = [IO.Path]::GetFullPath($entityRoot)
if (-not $(Test-Path $entityRoot))
{
    throw "Could not find the target directory for the entity:`n`t$entityRoot"
}

$templateFile = Resolve-Path "$scriptRoot\..\templates\entitytemplate.xml"

& $templateFile

Write-Verbose "--- $([IO.Path]::GetFileName($MyInvocation.MyCommand.Definition)) (action)"
