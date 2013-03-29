#=============================================================================
# Project: Baobab
# Author: Tobias Kiertscher
# Name: Expand-String.ps1
# Description: 
#   Replaces variables in a string by given values.
# Parameter: 
#   - text: 
#       The string with placeholders for varibales.
#       Example: "Hello ${Surname} ${Name}, your are ${age} years old."
#       Default value: $Input (Pipeline)
#   - variables:
#       A hash table with key-value-pairs representing the variables.
#       Example: @{Surname="Tobias"; Name="Kiertscher"; Age=26}
#=============================================================================

param (
	$text = $null,
	[System.Collections.Hashtable]$variables
)

Write-Verbose "+++ Expand-String.ps1"

if (-not $text)  { $text = $input }

foreach ($t in $text)
{
	if (-not $t) 
	{ 
		$null
		continue
	}
	$matches = [regex]::Matches($t, '\$\{(.*?)\}')
	$sb = New-Object System.Text.StringBuilder
	$lastPos = 0
	foreach	($match in $matches)
	{
		$sb = $sb.Append($t.Substring($lastPos, $match.Index - $lastPos))
		$varName = $match.Groups[1].Value
		if ($match.Value -and $variables.ContainsKey($varName))
		{
			$sb = $sb.Append($variables[$varName])
		}
		else
		{
			Write-Warning "The varibale '$varName' could not be resolved."
		}
		$lastPos = $match.Index + $match.Length
	}
	$sb = $sb.Append($t.Substring($lastPos))

	$sb.ToString()
}

Write-Verbose "--- Expand-String.ps1"
