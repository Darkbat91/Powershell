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
Date: 03NOV2014
Modified: 
	#>
[CmdletBinding()]
param(
	[Parameter(Mandatory=$true)]$Path,
    [Parameter(Mandatory=$false)]$DaysOld=30,
    [Parameter(Mandatory=$false)]$RemoveEmptyDir=$true
)


$Limit = (Get-Date).AddDays(0-$Daysold)

#Delete Files that are older than the limit
#Get-ChildItem -Path $Path -Recurse -Force -File | Where-Object { $_.CreationTime -lt $Limit } | Remove-Item -Force  
    #Only works on PS 3
Get-ChildItem -Path $path -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $Limit } | Remove-Item -Force
#If RemoveEmpty Dir is specified then delete the Empty Directories
If ($RemoveEmptyDir){
#Get-ChildItem -Path $Path -Recurse -Force -Directory | Where-Object { (Get-ChildItem -Path $_.FullName -Recurse -Force -File) -eq $null } | Remove-Item -Force
    #Only works on PS 3
Get-ChildItem -Path $path -Recurse -Force | Where-Object { $_.PSIsContainer -and (Get-ChildItem -Path $_.FullName -Recurse -Force | Where-Object { !$_.PSIsContainer }) -eq $null } | Remove-Item -Force -Recurse
}
}
