#=============================================================================
# Project: Baobab
# Author: Tobias Kiertscher
# Name: Build-Project.ps1
# Description: 
#   Runs the build script of the project.
#   The build script must be '<project root>\scripts\build.ps1'
# Parameter:
#   - configuration:
#       The build configuration name e.g. "Debug" or "Release"
#       There can be more than one configuration e.g. @("Debug", "Release")
#       Default value: @("Debug", "Release")
# Dependencies: 
#   EntityToolsLib.ps1
#=============================================================================

param (
	$configuration = @("Debug", "Release")
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
    -configuration $configuration

####### insert post action commands here #######


#######----------------------------------#######
