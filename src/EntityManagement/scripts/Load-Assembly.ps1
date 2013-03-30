#=============================================================================
# Project: Baobab
# Author: Tobias Kiertscher
# Name: Load-Assembly.ps1
# Description: 
#   Loads an assembly from the assembly directory of the entity management.
# Parameter: 
#   - assembly: 
#       The name of the assembly without file extension.
#=============================================================================

param (
	[string]$assembly
)

Write-Verbose "+++ Load-Assembly.ps1"

$scriptRoot = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent

$assembliesDir = "$scriptRoot\..\assemblies"
$dllFile = "$assembliesDir\$assembly.dll"
$exeFile = "$assembliesDir\$assembly.exe"

if (Test-Path $dllFile)
{
	$assemblyFile = $dllFile
}
elseif (Test-Path $exeFile)
{
	$assemblyFile = $exeFile
}
else
{
	throw "Could not find the specified assembly:`n`tAssembly: $assembly`n`tPath: $assembliesDir"
}

$assemblyObj = [Reflection.Assembly]::LoadFile($assemblyFile)

Write-Verbose "--- Load-Assembly.ps1"
