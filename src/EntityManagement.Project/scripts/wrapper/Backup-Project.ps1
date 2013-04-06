#=============================================================================
# Project: Baobab
# Author: Daniel Kiertscher
# SkriptName: Backup-Project.ps1
# Description: 
#   Creates a compressed backup of the project and stores it, annotated
#   with a timestamp, in the specified directory.
# Dependencies: 
#   EntityToolsLib.ps1
#=============================================================================

# determine local directory
$entityLocalScripts = [IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)
# load entity library
. "$entityLocalScripts\EntityToolsLib.ps1"

# determine action name
$actionName = Get-ActionName($MyInvocation.MyCommand.Definition)

# paths:
#   $entityRoot - root directory of the entity
#   $entityLocalScripts - local script directory in the entity
#   $entityManagement - root directory of the entity management system
#   $entityScripts - script directory of the entity management system
#   $entityActions - directory of the action scripts


####### insert pre action commands here  #######


#######----------------------------#######

$targetDir = [IO.Path]::Combine($entityRoot, "backup")

& "$entityActions\$actionName.ps1" `
	-entityRoot $entityRoot `
	-targetDir $targetDir `
	-zipFormat `
	-versionIgnore

####### insert post action commands here #######


#######----------------------------------#######

