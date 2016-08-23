function Uninstall-OldJava
{
<#
Used to uninstall Java from a system. Allows for version exceptions if needed.

#>
param ([hashtable]$ExceptionToKeep,
        [switch]$stopJava)



Import-Module PowerLogger -MinimumVersion 1.7 
if ((Get-Module -Name PowerLogger).Version.Major -ne 1){throw "Power Logger MAJOR version has incrimented since it was added to this script Errors may OCCUR"}
Start-Logging -LoggingLevel DEBUG -ScriptVersion '1.0' -LogPath C:\MSOL_Logs\ -ScriptName "Uninstall-OldJava"
$RegUninstallPaths = @( 
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall', 
    'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall') 

if ($stopJava.IsPresent)
{
Write-PLVerbose "Stopping Java Processes"
#Gets all Processes for Java and stops them so update can complete
Get-WmiObject Win32_Process | Where {$_.ExecutablePath -like '*Program Files*\Java\*'} |  
    Select @{n='Name';e={$_.Name.Split('.')[0]}} | Stop-Process -Force 

}

$UninstallSearchFilter = { ($_.GetValue('DisplayName') -like '*Java*') -and  
    ($_.GetValue('DisplayName') -notlike '*AUTO Updater*') -and
    (($_.GetValue('Publisher') -eq 'Oracle Corporation') -or 
    ($_.GetValue('Publisher') -eq 'Oracle')) -and 
    ($ExceptionToKeep -notcontains $_.GetValue('DisplayName'))}  

# Find Every Instance of Java Installed
foreach ($Path in $RegUninstallPaths) { 
    if (Test-Path $Path) { 
        $Javainstalls = Get-ChildItem $Path | Where $UninstallSearchFilter
        }}

write-pldebug "FOUND: $($Javainstalls.Count) Installs of Java"

#Make Sure to keep the latest Version on the system
$Latest = '0'
$LatestInstall = $null
foreach ($Javainstall in $Javainstalls)
    {
    if (Get-VersionCheck -VersionNumber $Javainstall.getvalue('DisplayVersion') -comparisonNumber $Latest)
        {
        $LatestInstall = $Javainstall
        $Latest = $LatestInstall.getvalue('DisplayVersion')

        }
    }

Write-PLVerbose "Latest install of Java is: $Latest"
#Uninstall if it is not the latest
$Javainstalls | where {$_.getvalue('DisplayVersion') -ne $Latest} | foreach {
Write-PLInfo "Removing Java $($_.getvalue('DisplayVersion'))"
Write-PLDebug "Uninstall String `'$($_.PSChildName)`'"
Start-Process -FilePath 'C:\Windows\System32\msiexec.exe' -ArgumentList "/x $($_.PSChildName) /qn /passive /l C:\MSOL_Logs\$($_.getvalue('DisplayVersion')).log" -Wait
}
