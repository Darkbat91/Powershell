function Start-Logging()
{
[CmdletBinding()]
param(
	[Parameter(Mandatory=$false)]$ScriptName=$null,
    [Parameter(Mandatory=$false)]$LogPath=$null,
    [validateset("INFO", "DEBUG", "Verbose", "None")]
    [Parameter(Mandatory=$false)]$LoggingLevel="INFO",
    [Parameter(Mandatory=$false)]$ScriptVersion
    )
    

<#
.SYNOPSIS
	Will enable logging for system
.DESCRIPTION
	Used as a helper script for other functions
.PARAMETER $ScriptName
	Allows the Script Name Log file to be renamed
.PARAMETER $LogPath
    Path that the log file is contained in
.PARAMETER $LoggingLevel
    Allows to set the logging level for run
.PARAMETER $ScriptVersion
    Allows for configureation of Script Version
.EXAMPLE
	
	
.NOTES	
Author: Micah
Date: 2012-12-1
	#>

Process{

if ($ScriptName -eq $null) # If script name was not set pull from Script
{
$ScriptNameOrigin = $MyInvocation.ScriptName
$Scriptname = Split-Path $ScriptNameOrigin -Leaf

$ScriptName = $ScriptName.Substring(0,$ScriptName.IndexOf("."))
}

if ($LogPath -eq $null)
{
$LogPath = Split-Path $ScriptNameOrigin -Parent
}




$SCRIPT:Fullpath = $LogPath + "\" + $ScriptName + ".log"
$SCRIPT:LoggingLevel = $LoggingLevel

IF ($SCRIPT:LoggingLevel -ne "None"){
#Show Logging start time
Add-content -path $Fullpath -value "____________________________________________________________________________________________________________________"
Add-Content -Path $Fullpath -Value "Started $LoggingLevel Logging for $ScriptName at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
If ($ScriptVersion -ne $null){Add-Content -Path $Fullpath -Value "Script Version: $ScriptVersion"}
Add-content -path $Fullpath -value "____________________________________________________________________________________________________________________"
}

}
}

export-modulemember -function Start-Logging

function Write-PLInfo()
{
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]$Message,
    [Parameter(Mandatory=$false)]$LogFile=$SCRIPT:Fullpath
    )
if ($SCRIPT:LoggingLevel -eq "INFO" -or $SCRIPT:LoggingLevel -eq "Debug" -or $SCRIPT:LoggingLevel -eq "Verbose")
    {
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $output = "$timestamp`t`[INFO]:`t`t$message"
    Add-Content -Path $LogFile -Value $output
    }
}

export-modulemember -function Write-PLInfo

function Write-PLDebug()
{
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]$Message,
    [Parameter(Mandatory=$false)]$LogFile=$SCRIPT:Fullpath
    )
if ($SCRIPT:LoggingLevel -eq "Debug")
    {
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $output = "$timestamp`t`[DEBUG]:`t$message"
    Add-Content -Path $LogFile -Value $output
    }
}

export-modulemember -function Write-PLDebug

function Write-PLVerbose()
{
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]$Message,
    [Parameter(Mandatory=$false)]$LogFile=$SCRIPT:Fullpath
    )
if ($SCRIPT:LoggingLevel -eq "Debug" -or $SCRIPT:LoggingLevel -eq "Verbose")
    {
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $output = "$timestamp`t`[Verbose]:`t$message"
    Add-Content -Path $LogFile -Value $output
    }
}

export-modulemember -function Write-PLVerbose
