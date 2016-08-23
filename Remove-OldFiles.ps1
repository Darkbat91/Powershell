Function Remove-OldFiles()


{
<#
.SYNOPSIS
	Deletes old files
.DESCRIPTION
	Deletes all files older than 30 days and removes any empty directories if desired
.PARAMETER $Path
	The Path to remove old files and directories
.PARAMETER $DaysOld
	The Number of Days old to delete files (Default 30 Days)
.PARAMETER $RemoveEmptyDir
    Specifies to remove the empty directories or not (Default True)	
.EXAMPLE
	Remove-OldFiles -path C:\TMP -DaysOld 15
    
    Deletes Files that are older than 15 days in the TMP directory.	
.NOTES	
    Author: Micah
    Creation Date: 20141114
    Last Modified: 20160106
    Version: 1.1

-----------------------------------------------------------------------------------------------------------------
CHANGELOG
-----------------------------------------------------------------------------------------------------------------
    1.0 Initial Release
	1.1 Created Relocation to archive files to a different directory
	#>
[CmdletBinding(DefaultParameterSetName='Remove')]
param(
	[Parameter(Mandatory=$true, ParameterSetName='Remove')][Parameter(Mandatory=$true, ParameterSetName='Archive')]$Path,
    [Parameter(Mandatory=$false)]$DaysOld=30,
    [Parameter(Mandatory=$false)]$RemoveEmptyDir=$true,
    [Parameter(Mandatory=$false, ParameterSetName='Archive')][switch]$Archive,
    [Parameter(Mandatory=$True, ParameterSetName='Archive')]$ArchiveDirectory,
    [Parameter(Mandatory=$false)]$Exclude=''
)


$Limit = (Get-Date).AddDays(0-$Daysold)


if ($Archive)
    {
    if ($Exclude -ne '')
        {
        $filestomove = Get-ChildItem -Path $path -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $Limit -and $_.FullName -notmatch $Exclude}
        }
    else
        {
        $filestomove = Get-ChildItem -Path $path -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $Limit}
        }

foreach ($file in $filestomove)
    {
    $newfile = ($file.fullname -replace [regex]::Escape($Path),$ArchiveDirectory)
    $newdir = ($file.DirectoryName -replace [regex]::Escape($Path),$ArchiveDirectory)
    if (!$(Test-path -Path $newdir))
        {
        New-Item -Path $newdir -ItemType Directory -Force | Out-Null
        }

    Move-Item -Path $File.FullName -Destination $newfile
    }

    }
    
else
    {

    #Delete Files that are older than the limit
    #Get-ChildItem -Path $Path -Recurse -Force -File | Where-Object { $_.CreationTime -lt $Limit } | Remove-Item -Force  
        #Only works on PS 3
    Get-ChildItem -Path $path -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $Limit -and $_.FullName -notmatch $Exclude} | Remove-Item -Force
    #If RemoveEmpty Dir is specified then delete the Empty Directories
    If ($RemoveEmptyDir){
    #Get-ChildItem -Path $Path -Recurse -Force -Directory | Where-Object { (Get-ChildItem -Path $_.FullName -Recurse -Force -File) -eq $null } | Remove-Item -Force
        #Only works on PS 3
    Get-ChildItem -Path $path -Recurse -Force | Where-Object { $_.PSIsContainer -and (Get-ChildItem -Path $_.FullName -Recurse -Force | Where-Object { !$_.PSIsContainer }) -eq $null -and $_.FullName -notmatch $Exclude} | Remove-Item -Force -Recurse
    }
    }
}
