#=============================================================================
# Project: Baobab
# Author: Tobias Kiertscher
# Name: Build-Profile.ps1
# Description: 
#   Builds a entity management profile in the directory:
#   bin\EntitManagement.<profile name>
#   An entity management profile constists of the entity base from
#   src\EntityManagement and the profile specific parts from 
#   src\EntityManagement.<profile name>
#   All required assemblies and runners are compiled and the necessary
#   resources like icons, templates and scripts are copied.
#   Further, the entity profile file is build by merging the profile.xml from
#   the base and the profile.xml from the specified profile.
# Parameters: 
#   - profilName: 
#       The name of the profile to build
#       Default value: 'bare'
#   - buildRunner:
#       (optional) 1 if the runner shall be compiled; otherwise 0.
#       If the parameter is not specified, a user prompt is shown.
# Dependencies: 
#   Prepare-Dir.ps1
#   Prepare-EmptyDir.ps1
#   Merge-Templates.ps1
#   New-EntityManagementFile.ps
#   Run-MsBuild.ps1
#   Build-Runner.ps1
#   Copy-VersionedDirectory.ps1 
# Remarks: 
#   Every profile is defined in a directory called 
#   src\EntityManagement.<profile name>
#   The structure of this directory must be like this:
#   EntityManagement.<profile name>
#      + scripts
#          + actions
#              - <action-name>.ps1
#          + wrapper
#              - <action-name>.ps1
#          - general scripts for this profile
#      + templates
#          + icons
#              - <action-name>.ico
#          - entitytemplate.xml
#          - <template name 1>.template
#          - <template name 2>.template.ps1
#=============================================================================
param (
	[string]$profileName = "bare",
	$buildRunner = "MessageBox"
)

# Pfade ermitteln
$myDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$src = Resolve-Path "$myDir\..\src"
$entityMgm = "$src\EntityManagement"
$entityScriptRoot = "$entityMgm\scripts"
$profileMgm = "$src\EntityManagement.$profileName"

$withRunner = $true
if ($buildRunner -eq "MessageBox") {
	# Windows.Forms-Assembly laden
	$wf = [Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

	# Prompt the user if the runner shall be compiled
	$withRunner = "Yes" -eq [Windows.Forms.MessageBox]::Show( `
		"Compile the runners?", `
		"Build-Project", "YesNo", "Question")
} elseif (-not $buildRunner) {
	$withRunner = $false
}
	
# prepare output directory
$bin = & "$myDir\Prepare-Dir.ps1" `
	-targetPath "$myDir\..\bin"
$out = & "$myDir\Prepare-EmptyDir.ps1" `
	-targetPath "$bin\EntityManagement.$profileName"

# set default reaction on errors to abort
$ErrorActionPreference = "Stop"

# copy command line tools
& "$myDir\Copy-VersionedDirectory.ps1" `
	-source "$myDir\..\lib\tools" `
	-target "$out\tools"

# copy EntityManagement base
& "$myDir\Copy-VersionedDirectory.ps1" `
	-source "$src\EntityManagement" `
	-target "$out"

# copy EntityManagement profile
# Remark: allready existing files from the base are overwritten
& "$myDir\Copy-VersionedDirectory.ps1" `
	-source "$src\EntityManagement.$profileName" `
	-target "$out"

# merge entity templates
& "$myDir\Merge-Templates.ps1" `
	-baseTemplateFile "$entityMgm\templates\entitytemplate.xml" `
	-profileTemplateFile "$profileMgm\templates\entitytemplate.xml" `
	-targetFile "$out\templates\entitytemplate.xml"

# create default entity management configuration
& "$myDir\New-EntityManagementFile.ps1" `
	-targetDir "$out\.." `
	-profileName $profileName `
	-entityManagementPath "EntityManagement.$profileName"

# compile helper assemblies
$assembliesDir = "$out\assemblies"
if (-not $(Test-Path $assembliesDir)) { mkdir $assembliesDir | Out-Null }
& "$myDir\Run-MsBuild.ps1" `
	-solution "$src\Baobab.sln" `
	-configuration "Distribution" `
	-properties @{ OutputPath = $assembliesDir }
Remove-Item "$assembliesDir\*.pdb"

# compiled entity creation runner
$newRunnerName = "New-" + $profileName.Substring(0,1).ToUpper() + $profileName.Substring(1)
& "$myDir\Build-Runner.ps1" `
	-name $newRunnerName `
	-scriptPath "scripts" `
	-scriptName "New-Entity.ps1" `
	-icoFile "$entityMgm\templates\icons\New-Entity.ico" `
	-targetDir "$out\.." `
	-profileName $profileName `
	-useEntityManagement

# compile action runner
if ($withRunner)
{
	# make shure the target directory exists
	$runnerDir = & "$myDir\Prepare-Dir.ps1" "$out\runner"
	
	# load entity template
	[xml]$template = Get-Content "$out\templates\entitytemplate.xml"
	
	# determine source directory for icons
	$actionIconDir = "$out\templates"
	if ($template.Template.Actions.iconDir)
	{
		$actionIconDir = Resolve-Path "$actionIconDir\$($template.Template.Actions.iconDir)"
	}
	
	# iterate over action tags
	$actionTags = $template.SelectNodes("/Template/Actions/Action")
	foreach ($actionTag in $actionTags)
	{
		# skip if action tag is empty
		if (-not $actionTag -or -not $actionTag.name) { continue }
		
		# build icon path
		$icoFile = [IO.Path]::Combine($actionIconDir, $actionTag.icon)
		if (-not $(Test-Path $icoFile))
		{
			$icoFile = Resolve-Path "$entityMgm\templates\icons\action.ico"
		}

		# compile the runner
		& "$myDir\Build-Runner.ps1" `
			-name $actionTag.name `
			-scriptPath ".entity\scripts" `
			-scriptName "$($actionTag.name).ps1" `
			-icoFile $icoFile `
			-targetDir $runnerDir `
			-profileName $profileName
	}
}