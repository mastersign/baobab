#=============================================================================
# Project: Baobab
# Author: Tobias Kiertscher
# Name: Build-Runner.ps1
# Description: 
#   Compiles a runner with the specified icon and a script path
# Parameters: 
#   - name:
#       The name of the runner
#   - scriptPath:
#       The relative or absolute path to the script directory
#   - scriptName:
#       The name of the script to run
#   - icoFile:
#       The absolute path to the runner icon
#   - targetDir:
#       The taret directory to store the compiled runner
#   - profileName:
#       The name of the profile to create the runner for
#   - useEntityManagement:
#       $true if a relative script path is relative to the root of
#       the entity management system; $false if a relative script path is
#       relative to the root of an entity
# Dependencies: 
#   Run-MsBuild.ps1
#   Prepare-Dir.ps1
#   Prepare-EmptyDir.ps1
#=============================================================================

param (
	[string]$name,
	[string]$scriptPath,
	[string]$scriptName,
	[string]$icoFile,
	[string]$targetDir,
	[string]$profileName = $null,
	[switch]$useEntityManagement = $false
)

# gather paths
$myDir = [IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)
$baobab = [IO.Path]::GetDirectoryName($myDir)
$projectScriptRoot = Resolve-Path "$baobab\src\EntityManagement.project\scripts"
$msbuild = Resolve-Path "$myDir\Run-MsBuild.ps1"

$runnerTemplateProjectDir = Resolve-Path "$baobab\src\RunnerTemplate"

# prepare temporary directory
$tmp = & "$myDir\Prepare-Dir.ps1" "$baobab\tmp"

### prepare runner project
$tempName = [IO.Path]::GetRandomFileName()
$runnerProjectDir = & "$myDir\Prepare-EmptyDir.ps1" "$tmp\$tempName"
& "$projectScriptRoot\Export-SvnDirectory.ps1" $runnerTemplateProjectDir $runnerProjectDir

### adapt runner template

# icon
Copy-Item $icoFile "$runnerProjectDir\action.ico"

# resource strings
$resFile = "$runnerProjectDir\Properties\Resources.resx"
[xml]$resDoc = Get-Content $resFile

# set script name
$scriptFileTag = $resDoc.SelectSingleNode("/root/data[@name='ScriptFile']/value")
$scriptFileTag.InnerText = $scriptName

# set script path
$scriptPathTag = $resDoc.SelectSingleNode("/root/data[@name='ScriptPath']/value")
$scriptPathTag.InnerText = $scriptPath

# set profile name
if ($profileName)
{
	$profileNameTag = $resDoc.SelectSingleNode("/root/data[@name='ProfileName']/value")
	$profileNameTag.InnerText = $profileName
}

# set reference point for relative script paths
if ($useEntityManagement)
{
	$useEntityManagementTag = $resDoc.SelectSingleNode("/root/data[@name='UseEntityManagement']/value")
	$useEntityManagementTag.InnerText = "true"
}

# save manipulated XML DOM
$ws = New-Object Xml.XmlWriterSettings
$ws.Encoding = [Text.Encoding]::UTF8
$ws.Indent = $true
$w = [Xml.XmlWriter]::Create($resFile, $ws)
$resDoc.Save($w)
$w.Close()

### compile
& $msbuild `
	-solution "$runnerProjectDir\RunnerTemplate.csproj" `
	-configuration "Release" `

# copy results to output directory
Copy-Item "$runnerProjectDir\bin\Release\RunnerTemplate.exe" "$targetDir\$name.exe"

### clean up
Remove-Item $runnerProjectDir -Recurse -Force
