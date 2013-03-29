# This script is an active template for the creation of .entity\entity.xml

param(
	[string]$targetPath,
	$processProperties = @{}
)

Write-Verbose "+++ Entity.template.ps1"

$now = [DateTime]::Now.ToShortDateString()

if (Test-Path $targetPath)
{
	[xml]$doc = [IO.File]::ReadAllText($targetPath, [Text.Encoding]::UTF8)
	
	$entity = $doc.Entity
	
	# update timestamp LastUpdate

	$lastUpdate = $entity.SelectSingleNode("LastUpdate")
	if (-not $lastUpdate)
	{
		$lastUpdate = $doc.CreateElement("LastUpdate")
		$entity.PrependChild($lastUpdate)
	}
	$lastUpdate.InnerText = $now
	
	# create GUID if not created yet
  
	$guid = $entity.SelectSingleNode("Guid")
	if (-not $guid)
	{
		$guid = $doc.CreateElement("Guid")
		$guid.InnerText = $([GUID]::NewGuid()).ToString()
		$entity.PrependChild($guid)
	}
	
	# update aspects

	$aspects = $entity.SelectNodes("Aspects/Aspect")
	foreach ($aspectName in $processProperties.AspectNames)
	{
		if (-not $aspectName) { continue }
	
		$found = $false
		foreach ($aspect in $aspects)
		{
			if ($aspect.InnerText.Trim() -ieq $aspectName)
			{
				$found = $true
				break
			}
		}
		if (-not $found)
		{
			$aspect = $doc.CreateElement("Aspect")
			$aspect.InnerText = $aspectName
			$aspectList = $entity.SelectSingleNode("Aspects")
			$aspectList.AppendChild($aspect)
		}
	}
	
	# update SVN ignore paths
	$svnProps = $entity.SelectSingleNode("SvnProperties")
	foreach ($iP in $processProperties.SvnIgnorePaths)
	{
		if (-not $svnProps.SelectSingleNode("Ignore[@path='$iP']"))
		{
			$ignoreTag = $doc.CreateElement("Ignore")
			$ignoreTag.SetAttribute("path", $iP)
			$svnProps.AppendChild($ignoreTag)
		}
	}
	
	$tempFilePath = [IO.Path]::GetTempFileName()
	$s = [IO.File]::Open($tempFilePath, [IO.FileMode]::Create)
	$ws = New-Object Xml.XmlWriterSettings
	$ws.Indent = $true
	$ws.Encoding = [Text.Encoding]::UTF8
	$w = [Xml.XmlWriter]::Create($s, $ws)
	$doc.Save($w)
	$w.Close()
	$s.Close()
	
	# replace old entity.xml with temporary
	
	Move-Item $tempFilePath $targetPath -Force
}
else
{
	$s = [IO.File]::Open($targetPath, [IO.FileMode]::Create)
	$ws = New-Object System.Xml.XmlWriterSettings
	$ws.Indent = $true
	$ws.Encoding = [Text.Encoding]::UTF8
	$w = [System.Xml.XmlWriter]::Create($s, $ws)
	
	$w.WriteStartElement("Entity")
		$w.WriteElementString("Name", $processProperties.EntityName)
		$w.WriteElementString("Profile", $processProperties.ProfileName)
		$w.WriteElementString("Guid", $([GUID]::NewGuid()).ToString())
		$w.WriteElementString("Created", $now)
		$w.WriteElementString("LastUpdate", $now)
		$w.WriteStartElement("Aspects")
		foreach ($aN in $processProperties.AspectNames)
		{
			if (-not $aN) { continue }
			$w.WriteElementString("Aspect", $aN)
		}
		$w.WriteEndElement()
		$w.WriteStartElement("SvnProperties")
		foreach ($iP in $processProperties.SvnIgnorePaths)
		{
			$w.WriteStartElement("Ignore")
			$w.WriteAttributeString("path", $iP)
			$w.WriteEndElement()
		}
		$w.WriteEndElement()
	$w.WriteEndElement()
	$w.Close()
	$s.Close()
}

Write-Verbose "--- Entity.template.ps1"
