#=============================================================================
# Project: Baobab
# Author: Tobias Kiertscher
# Name: Run-MsBuild.ps1
# Description: 
#   Runs the .NET build system msbuild for a VisualStudio solution
# Parameters: 
#   - solution: 
#       The solution file to build
#   - target:
#       The target or $null.
#       Default value: $null
#   - configuration:
#       The build configuration or $null.
#       Default value: $null
#   - properties:
#       A hash table with additional build properties
#   - version:
#       The version of the .NET framework to use for the build
#       Default value: "4.0.30319"
#=============================================================================

param(
	[string]$solution = $null,
	[string]$target = $null,
	[string]$configuration = $null,
	[System.Collections.Hashtable]$properties = @{},
	[string]$version = "4.0.30319"
)

# Pfade zusammensetzen
$msb64 = "${Env:SystemRoot}\Microsoft.NET\Framework64\v$version\msbuild.exe"
$msb = "${Env:SystemRoot}\Microsoft.NET\Framework\v$version\msbuild.exe"

# Prüfen ob msbuild.exe in 64Bit- oder 32Bit-Version verfügbar ist
if (Test-Path $msb64)
{
	$msbuild = $msb64
}
elseif (Test-Path $msb)
{
	$msbuild = $msb
}
else
{
	throw "Could not find msbuild.exe for MS .NET framework $version ."
}

# set build target if specified
if ($target)
{
	$target = "/t:$target"
}

# set build configuration if specified
if ($configuration)
{
	$properties.Configuration = $configuration
}

# translate into a list with command line arguments
$args = New-Object Collections.ArrayList
$args.Add($target) | Out-Null
$args.Add("/verbosity:minimal") | Out-Null
$args.Add("/noLogo") | Out-Null

foreach ($pName in $properties.Keys)
{
	$pValue = $properties[$pName]
	$args.Add("/p:$pName=$pValue") | Out-Null
}

$args.Add($solution) | Out-Null

# run msbuild.exe
&  $msbuild $args.ToArray()
