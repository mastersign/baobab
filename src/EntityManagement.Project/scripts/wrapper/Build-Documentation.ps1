#=============================================================================
# Project: Baobab
# Author: Tobias Kiertscher
# Name: Build-Project.ps1
# Description: 
#   Runs the build script of the project documentation.
#   The build script must be '<project root>\auto\builddoc.ps1'
# Dependencies: 
#   EntityToolsLib.ps1
#=============================================================================

param (
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
    -entityRoot $entityRoot

####### insert post action commands here #######


#######----------------------------------#######
