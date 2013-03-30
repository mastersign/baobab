#=============================================================================
# Project: Baobab
# Author: Tobias Kiertscher
# Name: Copy-VersionedDirectory.ps1
# Description: 
#   Copies the content of a directory recursivly and ignores all version
#   control informations.
# Parameter: 
#   - sourceDir: 
#       Source directory
#   - targetDir:
#       Target directory
#=============================================================================

param (
	[string]$sourceDir,
	[string]$targetDir
)

Write-Verbose "+++ Copy-VersionedDirectory.ps1"

function CopyVersionedDirContent([IO.DirectoryInfo]$src, [IO.DirectoryInfo]$trg)
{
	#Write-Host "--- Copy Directory Content ---`n`tFrom: $($src.FullName)`n`tTo:   $($trg.FullName)"
	if (-not $trg.Exists) 
	{ 
		$trg.Create()
		$trg.Attributes = $src.Attributes
	}
	
	foreach ($file in $src.GetFiles())
	{
		#Write-Host "--- Copy File ---`n`tFrom: $($file.FullName)`n`tTo:   $($trg.FullName)"
		$newFile = $file.CopyTo([IO.Path]::Combine($trg.FullName, $file.Name), $true)
	}
	
	foreach	($subdir in $src.GetDirectories())
	{
		if (($subdir.Name -ine ".svn") -and ($subdir.Name -ine ".git"))
		{
			$targetPath = [IO.Path]::Combine($trg.FullName, $subdir.Name)
			CopyVersionedDirContent $subdir $targetPath
		}
	}
}

$sourceDirInfo = New-Object IO.DirectoryInfo $sourceDir
$targetDirInfo = New-Object IO.DirectoryInfo $targetDir

CopyVersionedDirContent $sourceDirInfo $targetDirInfo

Write-Verbose "--- Copy-VersionedDirectory.ps1"
