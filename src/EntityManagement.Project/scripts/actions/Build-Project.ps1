#=============================================================================
# Project: Baobab
# Author: Tobias Kiertscher
# Name: Build-Project.ps1
# Description: 
#   Runs the build script of the project.
#   The build script must be '<project root>\auto\build.ps1'
# Parameter: 
#   - entityRoot: 
#       Path to the root of the entity
#       Default value: Current working directory
#   - configuration: 
#       The build configuration name e.g. "Debug" or "Release"
#       There can be more than one configuration e.g. @("Debug", "Release")
#       Default value: @("Debug", "Release")
# Dependencies: 
#   System.Windows.Forms
#=============================================================================

param (
    [string]$entityRoot = $(Get-Location),
    $configuration = @("Debug", "Release")
)

Write-Verbose "+++ $([IO.Path]::GetFileName($MyInvocation.MyCommand.Definition)) (action)"

$myDir = [IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)
$scriptRoot = [IO.Path]::GetDirectoryName($myDir)

$entityRoot = [IO.Path]::GetFullPath($entityRoot)
if (-not (Test-Path $entityRoot))
{
	throw "The project directory does not exist:`n`t$entityDir"
}

$buildScript = "$entityRoot\auto\build.ps1"
if (Test-Path $buildScript)
{
	& $buildScript `
		-scriptRoot $scriptRoot `
		-entityRoot $entityRoot `
		-configuration $configuration
}
else
{
	[Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
	[Windows.Forms.MessageBox]::Show( `
		"The project specific build script 'build.ps1' was not found.`n`t$buildScript", `
		"Build project", `
		"Ok", "Warning" )
}

Write-Verbose "--- $([IO.Path]::GetFileName($MyInvocation.MyCommand.Definition)) (action)"
