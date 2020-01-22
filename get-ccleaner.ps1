Add-Type -AssemblyName System.IO.Compression.FileSystem

Function Get-CCleaner{
[CmdletBinding()]
Param (
        [bool]$unzip = $true,
		[bool]$run = $true
)

	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	$wr = Invoke-WebRequest -Uri https://www.ccleaner.com/ccleaner/builds

	#$wr.ParsedHtml.all | select id -Unique

	$link = $wr.ParsedHtml.getElementById('GTM__download--CC-portableBuild') | select href

	$link.href
	
	$guid = new-guid

	Invoke-WebRequest -Uri $link.href -outfile $env:TEMP\ccleaner-$guid.zip

	if($unzip -eq $true){
		 [System.IO.Compression.ZipFile]::ExtractToDirectory($env:TEMP+'\ccleaner-'+$guid+'.zip', $env:TEMP+'\ccleaner_'+$guid)
	}

	if($run -eq $true){
		$exe_file = "$env:TEMP\ccleaner_$guid\CCleaner64.exe"
		start-process -filepath $exe_file
	}


}
