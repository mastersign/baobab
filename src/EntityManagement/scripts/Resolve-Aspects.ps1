#=============================================================================
# Project: Baobab
# Author: Tobias Kiertscher
# Name: Resolve-Aspects.ps1
# Description: 
#   Resolves all dependencies of a given aspect set with an aspect library.
# Parameter: 
#   - aspectLibrary: 
#       The aspect library from a file system template as XML element
#   - aspectNames:
#       An array with the requested aspect set
#   - processProperties:
#       A hash table with additional informations for the creation process
#=============================================================================

param (
    [System.Xml.XmlElement]$aspectLibrary,
    $aspectNames = @(),
    $processProperties = @{}
)

Write-Verbose "+++ Resolve-Aspects.ps1"

function GetAspectFromLib([System.Xml.XmlElement]$aspectLib, $aspectName)
{
    return $aspectLib.SelectSingleNode("//Aspect[@name='$aspectName']")
}

function ContainsAspect([System.Collections.ICollection]$aspects, [string]$aspectName)
{
    foreach ($a in $aspects)
    {
        if ($a.name -eq $aspectName)
        {
            return $true
        }
    }
    return $false
}

function ResolveAspects([System.Xml.XmlElement]$aspectLib, $aspectNames)
{
    $allAspects = New-Object System.Collections.ArrayList
    foreach ($aspectName in $aspectNames)
    {
		if (-not $aspectName) { continue }
		
        $aspectTag = GetAspectFromLib $aspectLib $aspectName
        if ($aspectTag)
        {
            $allAspects.Add($aspectTag) | Out-Null
        }
        else
        {
            Write-Warning "Could not find the aspect '$aspectName' in the given aspect library."
        }
    }
    $foundIncludes = New-Object System.Collections.ArrayList
    do
    {
        $foundIncludes.Clear() | Out-Null
        foreach ($aspect in $allAspects) 
        {
            $incTags = $aspect.SelectNodes("Include")
            foreach ($incTag in $incTags)
            {
                $incName = $incTag.InnerText
                if (-not $(ContainsAspect $allAspects $incName) `
                    -and -not $(ContainsAspect $foundIncludes $incName))
                {
                    $incAspect = GetAspectFromLib $aspectLib $incName
                    if ($incAspect)
                    {
                        $foundIncludes.Add($incAspect) | Out-Null
                    }
                    else
                    {
                        Write-Warning "Could not find the included aspect '$incName' in the given aspect library."
                    }
                }
            }
        }
        $allAspects.AddRange($foundIncludes) | Out-Null
    }
    while ($foundIncludes.Count -gt 0)
    return $allAspects
}

Write-Verbose "--- Resolve-Aspects.ps1"
return ResolveAspects $aspectLibrary $aspectNames