function Start-Backup
{
param (
[Parameter(Mandatory=$true, ParameterSetName='Backup')]
[ValidateScript({Test-Path $_ -pathtype container})]$SourceDIR,
[Parameter(ParameterSetName='Backup', Mandatory=$true)]$BackupDir="$env:TEMP\CopyBackup",
[Parameter(ParameterSetName='Backup', Mandatory=$false)][regex]$FileMask=".*",
[Parameter(ParameterSetName='Backup', Mandatory=$false)][switch]$RemoveOld,
[Parameter(ParameterSetName='Backup', Mandatory=$false)][int]$DaystoRetain='365')    

try {$ScriptDir = Split-Path -parent $MyInvocation.MyScriptName
Import-Module $ScriptDir\Powerlogger\Powerlogger.psm1 -MinimumVersion 1.8} catch{Import-Module Powerlogger -MinimumVersion 1.8}

if ((Get-Module -Name PowerLogger).Version.Major -ne 1){throw "Power Logger MAJOR version has incrimented since it was added to this script Errors may OCCUR"}
Start-Logging -ScriptVersion "1.4" -LoggingLevel DEBUG -OutputTerminal $true -TerminalLevel DEBUG



#region Param validation
$timeformat = 'yyyyMMdd-hhmmss'
$CopyDate = Get-Date -Format $timeformat
if (!$(Test-Path -Path $BackupDir))
    {
    mkdir $BackupDir
    Write-PLDebug -Message "Created Directory $DestinationDIR"
    }
    $SourceTree = Get-ChildItem $SourceDIR -Recurse
    $RootDIR = $SourceDIR
    $RootLength = $RootDIR.Length
#endregion

if($RemoveOld.IsPresent)
    {
    Write-PLInfo -Message "Checking old backups"
    $Backups = Get-ChildItem -Path $BackupDir
    Write-PLVerbose -Message "Found $($Backups.Count) Backups in Directory"
    foreach($backup in $Backups)
    {
    Write-PLDebug -Message "Verifying that $($backup.Name) is within Date"
    try{if([datetime]::ParseExact($Backup.name,$timeformat,$null) -lt (Get-Date).AddDays("-$DaystoRetain"))
        {
        Write-PLInfo -Message "Removing $($backup.Name) as it is older than $DaystoRetain Days" -emailline
        Remove-Item $Backup.fullname -Force -Recurse
        }
        }catch
        {
        Write-PLVerbose -Message "Not Checking $($backup.Name) Due to Not being in proper format"
        }
    } # End of Foreach Loop
    } # End of remove old

    
    $Sourcefiles = @($SourceTree | Where-Object {$_.mode -ne 'd----'})


    foreach($file in $SourceFiles)
        {

            #Backup file name file name + Date/time
        $BackupFilePath = "$BackupDir\$CopyDate"

        $FileName = $file.fullName

        if($FileName -notmatch $FileMask)
            {
            Write-PLDebug -Message "$FileName doesnt match $FileMask"
            continue
            }


    Write-PLVerbose -Message "Backing up $($file.name) to $BackupFilePath"
    if (!$(Test-path -path $BackupFIlePath))
    {mkdir $BackupFilePath | Out-Null}
    Copy-Item $FileName $BackupFilePath -Force -ErrorVariable MyError
        if ($MyError -ne $null)
            {
            Write-PLInfo -Message "ERROR: Unable to Backup file $FileName due to $($Myerror.exception)" -emailline
            Write-Error -Message "ERROR: Unable to Backup file $FileName due to $($Myerror.exception)"
            continue
            }
    }
}
