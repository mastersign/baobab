#=============================================================================
# Project: Baobab
# Author: Tobias Kiertscher
# Name: Set-DirectoryIcon.ps1
# Description:
#   Sets a custom icon for a folder. Therefore, the dektop.ini is created
#   or extended for the target folder. Additionally, the system attribute is
#   set for the folder to notify the os about the dektop.ini.
# Parameter: 
#   - dir: 
#       The target folder
#   - iconFile:
#       The path of the icon file
#   - iconStore:
#       A directory to store the icon or $null. In case a directory is given,
#       the icon file is linked with a relative path from the desktop.ini;
#       otherwise the absolute path of the given icon file is used.
#       Default value: $null
# Dependencies: 
#   Set-IniFileValue.ps1
#=============================================================================

param(
	[string]$dir,
	[string]$iconFile,
	[string]$iconStore = $null
)

Write-Verbose "+++ Set-DirectoryIcon.ps1"

$scriptRoot = [IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)
& "$scriptRoot\Load-Assembly.ps1" "FileSystemToolbox"

if (-not $(Test-Path $dir)) 
{
	throw "Could not find the specified directory:`n`t$dir"
}

if (-not $(Test-Path $iconFile))
{
	throw "Could not find the specified icon file:`n`t$iconFile"
}

$desktopIniFile = [System.IO.Path]::Combine($dir, "desktop.ini")
$iconFileName = [System.IO.Path]::GetFileName($iconFile)

if ($iconStore)
{
	if (-not $(Test-Path $iconStore))
	{
		throw "The directory for storing the icon file was not found:`n`t$iconStore"
	}
	Copy-Item $iconFile $iconStore
	$relativePath = [net.kiertscher.toolbox.filesystem.DirectoryTools]::RelativePathTo($dir, "$iconStore\$iconFileName")
	& "$scriptRoot\Set-IniFileValue.ps1" $desktopIniFile ".ShellClassInfo" "IconFile" $relativePath | Out-Null
	& "$scriptRoot\Set-IniFileValue.ps1" $desktopIniFile ".ShellClassInfo" "IconIndex" "0" | Out-Null
}
else
{
	Copy-Item $iconFile $dir
	$newIconFile = [System.IO.Path]::Combine($dir, $iconFileName)
	$newIconFileInfo = New-Object System.IO.FileInfo $newIconFile
	$newIconFileInfo.Attributes = $($newIconFileInfo.Attributes -bor [System.IO.FileAttributes]::Hidden)
	& "$scriptRoot\Set-IniFileValue.ps1" $desktopIniFile ".ShellClassInfo" "IconFile" $iconFileName | Out-Null
	& "$scriptRoot\Set-IniFileValue.ps1" $desktopIniFile ".ShellClassInfo" "IconIndex" "0" | Out-Null
}

$desktopIniFileInfo = New-Object System.IO.FileInfo $desktopIniFile
$desktopIniFileInfo.Attributes = $desktopIniFileInfo.Attributes `
	-bor [System.IO.FileAttributes]::Hidden

$dirInfo = New-Object System.IO.DirectoryInfo $dir
$dirInfo.Attributes = $dirInfo.Attributes `
	-bor [System.IO.FileAttributes]::System

Write-Verbose "--- Set-DirectoryIcon.ps1"
