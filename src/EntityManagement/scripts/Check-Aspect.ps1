#=============================================================================
# Project: Baobab
# Author: Tobias Kiertscher
# Name: Check-Aspect.ps1
# Description: 
#   Checks if a template element in the entity template is triggered by
#   the given aspects.
# Parameter: 
#   - element: 
#       A XML element from the entity template
#   - claimedAspects:
#       An array with all aspects selected for the target entity
#=============================================================================

param (
	[System.Xml.XmlElement]$element, 
	$claimedAspects
)

Write-Verbose "+++ Check-Aspect.ps1"

$aspects = $element.SelectNodes("Aspect | ExcludeAspect")

$foundClaimedAspect = $false

$active = $false
$excluded = $false

foreach ($claimedAspect in $claimedAspects)
{
	$foundClaimedAspect = $true

	foreach	($aspect in $aspects)
	{
		if ($aspect.LocalName -eq "Aspect" `
			-and $aspect.InnerText -eq "default")
		{
			$active = $true
			$excluded = $false
		}
		elseif ($aspect.LocalName -eq "Aspect" `
			-and $aspect.InnerText -eq $claimedAspect)
		{
			$active = $true
			$excluded = $false
		}
		elseif ($aspect.LocalName -eq "ExcludeAspect" `
			-and $aspect.InnerText -eq $claimedAspect)
		{
			$active = $false
			$excluded = $true
		}
	}
	if ($excluded)
	{
		return $false
	}
}

if (-not $foundClaimedAspect)
{
	foreach	($aspect in $aspects)
	{
		if ($aspect.LocalName -eq "Aspect" `
			-and $aspect.InnerText -eq "default")
		{
			$active = $true
			break
		}
	}
}

Write-Verbose "--- Check-Aspect.ps1"
return $active
