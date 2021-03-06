#=============================================================================
# Project: Baobab
# Author: Tobias Kiertscher
# Name: New-FileSystemStructure.ps1
# Description: 
#   Creates, restores, and extends a file system structure based on a given
#   XML-template and a list of requested aspects.
# Parameter: 
#   - targetDir: 
#       Root directory for the file system structure
#   - structureTemplatePath:
#       Path to the XML-template file
#   - aspectNames:
#       An array with the requested entity aspects
#   - processProperties:
#       A has table with additional informations for the creation process.
# Dependencies: 
#   Expand-String.ps1
#   Check-Aspect.ps1
#   Set-DirectoryIcon.ps1
#   New-FileFromTemplate.ps1
#=============================================================================

param(
    [string]$targetDir,
    [string]$structureTemplatePath,
    $aspectNames = @(),
    $processProperties = @{}
)

Write-Verbose "+++ New-FileSystemStructure.ps1"

$scriptRoot = [IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)

$parsingResult = & "$scriptRoot\Parse-Template.ps1" `
	$structureTemplatePath $aspectNames $processProperties

$template = $parsingResult.Template
$aspectNames = $parsingResult.AspectNames
$processProperties.AspectNames = $aspectNames

$processProperties.VersionIgnorePaths = New-Object Collections.ArrayList

function AddVersionIgnorePath([string]$path)
{
	if (-not $processProperties.VersionIgnorePaths.Contains($path))
	{
		$processProperties.VersionIgnorePaths.Add($path) | Out-Null
	}
}

function PreprocessTemplate([Xml.XmlElement]$descriptor, [string]$path = "")
{
	if ($descriptor.versionIgnore)
	{
		AddVersionIgnorePath $path
	}

	foreach ($dir in $descriptor.SelectNodes("Dir"))
	{
		$name = & "$scriptRoot\Expand-String.ps1" $dir.name $processProperties
		$subPath = [IO.Path]::Combine($path, $name)
		PreprocessTemplate $dir $subPath
	}
	
	foreach ($file in $descriptor.SelectNodes("File"))
	{
		$name = & "$scriptRoot\Expand-String.ps1" $file.name $processProperties
		$filePath = [IO.Path]::Combine($path, $name)
		if ($file.versionIgnore)
		{
			AddVersionIgnorePath $filePath
		}
	}
}

function FindIconStore([string]$targetDir, [xml]$template)
{
	$iconStoreTag = $template.SelectSingleNode("//Dir[@iconStore='true']")
	if ($iconStoreTag)
	{
		$path = ""
		$tag = $iconStoreTag
		while (($tag.GetType() -eq [Xml.XmlElement]) `
			-and ($tag.LocalName -eq "Dir"))
		{
			$dirName = $tag.name | `
				& "$scriptRoot\Expand-String.ps1" -variables $processProperties
			$path = $dirName + "\" + $path
			$tag = $tag.ParentNode
		}
		return [IO.Path]::Combine($targetDir, $path)
	}
	else
	{
		return $null
	}
}

function BuildLevel
{
	param (
		[Xml.XmlElement]$descriptor, 
		$aspectNames, 
		[string]$targetDir,
		[string]$iconSource, 
		[string]$iconStore
	)
	
	# Check if the current directory has a specified icon source
	if ($descriptor.iconSource)
	{
		$newIconSource = $descriptor.iconSource
		# If the icon is specified with a relative path resolve the path
		if (-not [IO.Path]::IsPathRooted($newIconSource))
		{
			$newIconSource = [IO.Path]::Combine($templateDir, $newIconSource)
		}
		# If the given directory exists use as current icon source folder
		if (Test-Path $newIconSource)
		{
			$iconSource = $newIconSource
		}
	}
	
	# Check if the current directory has a specified icon
	if ($descriptor.icon)
	{
		$iconFile = $descriptor.icon
		# Check if the path is relative and resolve to aboslute path
		if (-not [IO.Path]::IsPathRooted($iconFile))
		{
			$iconFile = [IO.Path]::Combine($iconSource, $descriptor.icon)
		}
		
		# Use the generic 'folder.ico', if the specified icon file can not be found
		if (-not $(Test-Path $iconFile))
		{
			Write-Warning "Die Symboldatei wurde nicht gefunden. Es wird versucht 'folder.ico' zu verwenden:`n`t$iconFile"
			$iconFile = [IO.Path]::Combine($iconSource, "folder.ico")
		}
		
		# Apply the icon to the current directory
		trap [Exception]
		{
			Write-Warning $_.Exception.Message
			continue
		}
		& "$scriptRoot\Set-DirectoryIcon.ps1" `
			-dir $targetDir `
			-iconFile $iconFile `
			-iconStore $iconStore
	}
	
	# Create the sub directories
	foreach	($dir in $descriptor.SelectNodes("Dir"))
	{
		# Check if this directory is required for the aspects set
		if (& "$scriptRoot\Check-Aspect.ps1" $dir $aspectNames)
		{
			# Resolve variables in the directory name
			$dirName = $dir.name | `
				& "$scriptRoot\Expand-String.ps1" -variables $processProperties
			
			# Build the path
			$dirPath = [IO.Path]::Combine($targetDir, $dirName)
			
			# Create the directory in case it does not exist
			if (-not $(Test-Path $dirPath)) 
			{
				mkdir $dirPath | Out-Null
			}
			$dirInfo = New-Object System.IO.DirectoryInfo $dirPath
			
			# Hide the directory if necessary
			if ($dir.hidden)
			{
				$dirInfo.Attributes = $dirInfo.Attributes -bor [IO.FileAttributes]::Hidden
			}
			
			# Create sub elements int the current sub directories
			BuildLevel $dir $aspectNames $dirPath $iconSource $iconStore
		}
	}
	
	# Create all files
	foreach ($file in $descriptor.SelectNodes("File"))
	{
		# Check if this file is required by the aspect set
		if (& "$scriptRoot\Check-Aspect.ps1" $file $aspectNames)
		{
			& "$scriptRoot\New-FileFromTemplate.ps1" `
				-targetDir $targetDir `
				-fileDescriptor $file `
				-aspectNames $aspectNames `
				-processProperties $processProperties
		}
	}
}

# Determine the directory of the XML template
$templateDir = [IO.Path]::GetDirectoryName($structureTemplatePath)

# Determine the default icon source
$iconStore = FindIconStore $targetDir $template

# Create the default icon store if not existing
if ($iconStore -and -not (Test-Path $iconStore))
{
	mkdir $iconStore | Out-Null
}

# Start preprocessing
PreprocessTemplate $template.Template.Structure

# Trigger the creation process at the root directory
BuildLevel $template.Template.Structure $aspectNames $targetDir $templateDir $iconStore

Write-Verbose "--- New-FileSystemStructure.ps1"
