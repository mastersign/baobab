#=============================================================================
# Project: Baobab
# Author: Tobias Kiertscher
# Name: New-EntityManagementFile.ps1
# Description: 
#   Creates the default entity management configuration file for 
#   a given profile
# Parameters: 
#   - targetDir: 
#       The target directory to store the file
#   - profileName:
#       The profile name to create the configuration file for
#   - entityManagementPath:
#       The relative path from the $targetDir to the root directory of the
#       entity management system
#=============================================================================

param (
	[string]$targetDir,
	[string]$profileName,
	[string]$entityManagementPath
)

$ws = New-Object Xml.XmlWriterSettings
$ws.Encoding = [Text.Encoding]::UTF8
$ws.Indent = $true
$ws.IndentChars = "    "
$w = [Xml.XmlWriter]::Create("$targetDir\entitymanagement.$profileName.xml", $ws)

$w.WriteStartElement("EntityManagement")
$w.WriteElementString("RootPath", $entityManagementPath)

$w.WriteStartElement("SvnRepository")
$w.WriteAttributeString("name", "Localhost Test")
$w.WriteAttributeString("url", "https://localhost/svn/test/")
$w.WriteEndElement()

$w.WriteStartElement("SvnRepository")
$w.WriteAttributeString("name", "File System Test")
$w.WriteAttributeString("path", "..\..\TestRepository")
$w.WriteEndElement()

$w.WriteEndElement()

$w.Close()
