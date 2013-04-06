#=============================================================================
# Project: Baobab
# Author: Autor
# Name: New-Prototype.ps1
# Description: 
#   Creates a new sub project for a prototype
# Parameter: 
#   - entityRoot: 
#       Path to the root of the entity
#       Default value: Current working directory
# Dependencies: 
#   Build-Entity.ps1
#   System.Windows.Forms
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
    throw "Could not find the target directory for the entity:`n`t$entityDir"
}

[Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null

$entityName = Read-Host "Name"
if (-not $entityName)
{
	[Windows.Forms.MessageBox]::Show(`
		"The process was canceled.", `
		"Create prototype", "Ok", "Information")
	return
}

$protoDir = [IO.Path]::Combine($entityRoot, "proto")
$targetDir = [IO.Path]::Combine($protoDir, $entityName)
if (Test-Path $targetDir)
{
	$dlgResult = [Windows.Forms.MessageBox]::Show( `
		"The folder '$entityName' allready exists. Use anyway?", `
		"Create prototype", "YesNo", "Question")
	if ($dlgResult -eq "No")
	{
		return
	}
}
else
{
	mkdir $targetDir | Out-Null
}

& "$scriptRoot\Build-Entity.ps1" `
	-entityRoot $targetDir `
	-entityName $entityName `
	-promptForAspects

Write-Verbose "--- $([IO.Path]::GetFileName($MyInvocation.MyCommand.Definition)) (action)"
