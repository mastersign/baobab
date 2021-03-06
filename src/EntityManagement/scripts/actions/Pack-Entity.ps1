#=============================================================================
# Project: Baobab
# Author: Daniel Kiertscher
# Name: Pack-Entity.ps1
# Description: 
#   Packs the entity as ZIP or self-extracting SFX archive.
#   The file name of the archive is: '<entity name> <date> <time>'
# Parameter: 
#   - entityRoot: 
#       Path to the root of the entity
#       Default value: Current working directory
#   - targetDir:
#       Target directory to store the archive
#       Default value: Desktop
#   - versionIgnore:
#       $true, if folder named '.svn' or '.git' shell be excluded;
#       otherwise $false
#       Default value: $false
#   - zipFormat:
#       $true, if the archive shall be in ZIP format, $false for 
#       self-extracting SFX format
#       Default value: $false
#   - promptVersionIgnore:
#       $true, if a user prompt shall be displayed to override $versionIgnore;
#       otherwise $false.
#       Default value: $false
#   - promptZipFormat:
#       $true, if a user prompt shall be displayed to override $zipFormat;
#       otherwise $false
#       Default value: $false
# Dependencies: 
#   System.Windows.Forms
#   Choose-SaveFile.ps1
#   tools\7zip\7za.exe
#=============================================================================

param (
	[string]$entityRoot = $(Get-Location),
	[string]$targetDir = [Environment]::GetFolderPath("Desktop"),
	[switch]$versionIgnore = $false,
	[switch]$zipFormat = $false,
# dominant parameters
	[switch]$promptVersionIgnore = $false,
	[switch]$promptZipFormat = $false
)

Write-Verbose "+++ $([IO.Path]::GetFileName($MyInvocation.MyCommand.Definition)) (action)"


$entityActions = [IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)
$entityManagement = "$entityActions\..\.."
$entityScripts = [IO.Path]::Combine($entityManagement,"scripts")
$entityName = [IO.Path]::GetFileName($entityRoot)

# load WindowsForms assembly
[Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null

# check and format entityRoot
if (-not $(Test-Path $entityRoot))
{
    throw "Could not find the target directory for the entity:`n`t$entityRoot"
}
$entityRoot = Resolve-Path $entityRoot

# check target path for archive
if ($targetDir -and -not $(Test-Path $targetDir))
{
    throw "Das übergebene Zielverzeichnis für das Archiv existiert nicht:`n`t$targetDir"
}

# format date and time string
$timeStamp = [DateTime]::Now.ToString("yyyy-MM-dd HHmmss")

# get path to 7zip
$7Zip = & "$entityScripts\Get-Tool.ps1" "7zip"

# Determine configuration with dialogs

# Dialog: Option ignore versioning folders? (Default: "Yes" include versioning)
if (((Test-Path "$entityRoot\.svn") -or (Test-Path "$entityRoot\.git")) -and $promptVersionIgnore)
{
	$result = [Windows.Forms.MessageBox]::Show("Include version control information?", "Pack-Entity", "YesNoCancel", "Question")
	if ($result -eq "Cancel") { return }
	$versionIgnore = !$($result -eq "Yes")
}

# Dialog: Option Zip? (Default: "Yes" SFX)
if ($promptZipFormat)
{
	$result = [Windows.Forms.MessageBox]::Show("Create self-extracting SFX archive?", "Pack-Entity", "YesNoCancel", "Question")
	if ($result -eq "Cancel") { return }
	$zipFormat = !$($result -eq "Yes")
}

# build file extension and archiver arguments from the configuration
if ($versionIgnore)
{
	$paramIgnore = "`"-x!.svn`" `"-x!.git`""
}
else
{
	$paramIgnore = ""
}
if ($zipFormat)
{
	$fileType = ".zip"
	$paramType = "-tzip"
	$filter = "Zip-Archiv (*.zip)|*.zip"
}
else
{
	$fileType = ".exe"
	$paramType = "-sfx7z.sfx"
	$filter = "SFX-Archiv (*.exe)|*.exe"
}

# Dialog: Determine target path (directory, name and file extension)
if ($targetDir -eq [Environment]::GetFolderPath("Desktop"))
{
	$targetPath = & "$entityScripts\Choose-SaveFile.ps1" `
				-title "Save archive..." `
				-filter $filter `
				-initDir $targetDir `
				-initFileName "$entityName $timeStamp$fileType"
	if (-not $targetPath) {	return }
}
else
{
	$targetPath = "$targetDir\$entityName $timeStamp$fileType"
}

# Determine number of processor cores and decide over load balance
$threads = [Math]::Max([Environment]::ProcessorCount / 2, 1)

# call 7-Zip with arguments
& $7Zip "a" $paramType $targetPath $entityRoot $paramIgnore "-r" "–ssw" "-mx=5" "-mmt=$threads"

Write-Verbose "--- $([IO.Path]::GetFileName($MyInvocation.MyCommand.Definition)) (action)"
