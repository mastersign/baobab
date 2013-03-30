#=============================================================================
# Project: Baobab
# Author: Daniel Kiertscher
# SkriptName: Pack-Entity.ps1
# Parameter:
#   -targetDir
# Description: 
#   Packs the entity as ZIP or self-extracting SFX archive.
#   The file name of the archive is: '<entity name> <date> <time>'
# Dependencies: 
#   EntityToolsLib.ps1
#=============================================================================
param (
	[string]$targetDir = [Environment]::GetFolderPath("Desktop")
)

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


#######----------------------------------#######

& "$entityActions\$actionName.ps1" `
    -entityRoot $entityRoot `
	-targetDir $targetDir `
	-promptVersionIgnore `
	-promptZipFormat
    ##EDIT##

####### insert post action commands here #######


#######----------------------------------#######

