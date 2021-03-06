#=============================================================================
# Project: Baobab
# Author: Tobias Kiertscher
# Name: Add-Aspect.ps1
# Description: 
#   Adds on or more aspects to an existing entity
# Parameter: 
#   - entityRoot: 
#       Path to the root of the entity
#       Default value: Current working directory
#   - aspectNames:
#       The requested aspects or $null, if a selection dialog shell be shown
# Dependencies: 
#   Get-EntityInfo.ps1
#   Choose-FromList.ps1
#   Build-Entity.ps1
#=============================================================================

param (
    [string]$entityRoot = $(Get-Location),
	$aspectNames = @()
)

Write-Verbose "+++ $([IO.Path]::GetFileName($MyInvocation.MyCommand.Definition)) (action)"

$myDir = [IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)
$scriptRoot = [IO.Path]::GetDirectoryName($myDir)

$entityRoot = [IO.Path]::GetFullPath($entityRoot)
if (-not $(Test-Path $entityRoot))
{
    throw "Could not find the target directory for the entity:`n`t$entityRoot"
}

if (-not $aspectNames -or $($aspectNames.Length -eq 0))
{
	$entityInfo = & "$scriptRoot\Get-EntityInfo.ps1" $entityRoot
	$usedAspectTags = $entityInfo.SelectNodes("/Entity/Aspects/Aspect")
	$usedAspectNames = New-Object Collections.ArrayList
	$sb = New-Object Text.StringBuilder
	$sb = $sb.AppendLine("Selected so far:")
	foreach ($at in $usedAspectTags)
	{
		if (-not $at) { continue }
		$aN = $at.InnerText.Trim()
		$usedAspectNames.Add($aN) | Out-Null
		$sb = $sb.Append("- ")
		$sb = $sb.AppendLine($aN)
	}
	
	[xml]$template = Get-Content "$scriptRoot\..\templates\entitytemplate.xml"
	$newAspectTags = $template.SelectNodes("//AspectLibrary/Aspect")
	$newAspectNames = New-Object Collections.ArrayList
	foreach ($at in $newAspectTags)
	{
		$newAspectNames.Add($at.name) | Out-Null
	}
	
	$aspectNames = & "$scriptRoot\Choose-FromList.ps1" `
		-title "Add aspects..." `
		-message $sb.ToString() `
		-list $newAspectNames
}

& "$scriptRoot\Build-Entity.ps1" `
	-entityRoot $entityRoot `
	-aspectNames $aspectNames

Write-Verbose "--- $([IO.Path]::GetFileName($MyInvocation.MyCommand.Definition)) (action)"
