#=============================================================================
# Project: Baobab
# Author: Tobias Kiertscher
# Name: Add-Aspect.ps1
# Description: 
#   Adds on or more aspects to an existing entity
# Parameter: 
#   - aspectNames: 
#       The requested aspects or $null, if a selection dialog shell be shown
# Dependencies: 
#   EntityToolsLib.ps1
#=============================================================================
param (
	$aspectNames = $null
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


#######----------------------------#######

& "$entityActions\$actionName.ps1" `
    -entityRoot $entityRoot `
    -aspectNames $aspectNames

####### insert post action commands here #######


#######----------------------------------#######
