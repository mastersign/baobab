#=============================================================================
# Project: Baobab
# Author: Tobias Kiertscher
# Name: Get-ToolPath.ps1
# Description: 
#   Returns the absolute path to a tool. The file
#   <EntityManagement>\tools\tools.xml is used as index for the discovery.
# Parameter:
#   - name:
#       The name of the tool
#=============================================================================

param (
	[string]$name
)

Write-Verbose "+++ Get-ToolPath.ps1"

$myDir = [IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)
$entityManagement = [IO.Path]::GetDirectoryName($myDir)

$ret = $null
$toolsRootPath = [IO.Path]::Combine($entityManagement, "tools")
$toolsLibFile = [IO.Path]::Combine($toolsRootPath, "tools.xml")
if (Test-Path $toolsLibFile)
{
	$toolsLib = [xml]$(Get-Content $toolsLibFile)
	$toolElement = $toolsLib.SelectSingleNode("//Tool[@name='$name']")
	if ($toolElement)
	{
		$path = $toolElement.InnerXml
		if (-not [IO.Path]::IsPathRooted($path))
		{
			$path = [IO.Path]::Combine($toolsRootPath, $path)
		}
		if (Test-Path $path)
		{
			$ret = $path
		}
		else
		{
			Write-Warning "Could not find the tool '$name'.`n`t$path`n`t$toolsLibFile"
		}
	} 
	else
	{
		Write-Warning "The tool '$name' is unknown to Baobab.`n`t$toolsLibFile"
	}
}
else
{
	Write-Warning "Could not find the tool index file.`n`t$toolsLibFile"
}

Write-Verbose "--- Get-ToolPath.ps1"
return $ret