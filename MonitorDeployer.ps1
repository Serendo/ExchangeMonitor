<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2016 v5.2.129
	 Created on:   	2016-10-30 20:56
	 Created by:   	Scorpion
	 Organization: 	
	 Filename:     	OverMon.ps1
	===========================================================================
	.DESCRIPTION
		A Script that used to sync scripts, tasks and files from a configuration server and then make a sucessful mark on them.
		This script should be configured to run regularly.
#>

#region Functions
function Get-ADSIComputerSite
{
    [System.DirectoryServices.ActiveDirectory.ActiveDirectorySite]::GetComputerSite()
}
Function Touch-File
{
    $file = $args[0]
    if($file -eq $null) {
        throw "No filename supplied"
    }

    if(Test-Path $file)
    {
        (Get-ChildItem $file).LastWriteTime = Get-Date
    }
    else
    {
        echo $null > $file
    }
}
#endregion

function Pull-Configuration
{
	param
	(
		[array]$serverList,
		[String]$configPath = 'ExchangeMonitor\Configuration',
		[String]$markPath = 'ExchangeMonitor\MonMarks',
		[String]$localPath = 'D:\ExchangeMonitor'
	)
	
	$siteName = (Get-ADSIComputerSite).Name
	$sucess = $false
	foreach ($server in $serverList) {
		if (Test-Path "\\$server\$configPath\")
		{
			$list = Get-ChildItem "\\$server\$configPath\*.zip"
			
			foreach ($Taskfile in $list) {
				Copy-Item $Taskfile -Destination $localPath
			}
			Touch-File "\\$server\$markPath\$siteName"
			
			break
		}
	}
	if ($sucess)
	{
		return $config
	}
	else
	{
		return $null
	}
}

#Main
$config = Pull-Configuration -serverList DC1,DC2
