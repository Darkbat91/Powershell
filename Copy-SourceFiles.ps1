function Copy-SourceFiles
{
<#
.SYNOPSIS
    Copys Files from original Source to new Location
.DESCRIPTION
    Deploys Files to a web service and maintains a backup of the files incase there was a problem
.PARAMETER SourceDIR
        Directory that contains the files to be deployed
.PARAMETER DestinationDIR
        Directory that Files should be deployed to, Can Have files or be empty
.PARAMETER PurgeFileAfterCopy
        Removes files from the source Directory After successful Deployment to Destination
.PARAMETER PurgeDIRandFiles
        Removes files and Directories from the source Directory After successful Deployment to Destination
.EXAMPLE
    Copy-SourceFiles -SourceDIR C:\Todeploy -DestinationDIR \\PRoductionServer\Webdirectory -Purge
        Will deploy files from the C:\Todeploy folder to the remote productionserver and will delete all files from the toDeploy Folder
.NOTES
    Author: Micah
    Creation Date: 
    Last Modified: 
    Version: 1.4

-----------------------------------------------------------------------------------------------------------------
CHANGELOG
-----------------------------------------------------------------------------------------------------------------
    1.0 - Initial Release
    1.1 - Removed Directory iteration due to amount of time it was taking, System will only look for files now.
    1.2 - Added a Remote Backup path for Remote backup of files.
    1.4 - Created Backups based on the Date of deploy as well as a restore functionality
#>

### Params ###
param (
[Parameter(Mandatory=$true, ParameterSetName='Deployment')]
[ValidateScript({Test-Path $_ -pathtype container})]$SourceDIR,
[Parameter(Mandatory=$true, ParameterSetName='Deployment')][Parameter(Mandatory=$true, ParameterSetName='Rollback')]$DestinationDIR,
[Parameter(ParameterSetName='Deployment')][switch]$Purge,
[Parameter(ParameterSetName='Deployment')][switch]$CreateAllDirectories,
[Parameter(ParameterSetName='Deployment')][switch]$BackupFilesToRemote,
[Parameter(ParameterSetName='Deployment', Mandatory=$false)]
[Parameter(ParameterSetName='Rollback', Mandatory=$true)]$BackupDir="$env:TEMP\CopyBackup",
[Parameter(ParameterSetName='Rollback')][switch]$RollbackLast,
[Parameter(ParameterSetName='Rollback')][switch]$Rollback)
#[switch]$all allows just using -all to make something happen
#[ValidateSet("one", "two")
#$State Makes state only able to be one or two

### Configuration ###
# < Imports for usability >
try {$ScriptDir = Split-Path -parent $MyInvocation.MyScriptName
Import-Module $ScriptDir\Powerlogger\Powerlogger.psm1} catch{Import-Module Powerlogger}
Start-Logging -ScriptVersion "1.4" -LoggingLevel INFO


### Script Body ###
    $CopyDate = Get-Date -Format "yyyyMMdd-hhmmss"

#region Param validation
if (!$(Test-Path -Path $BackupDir) -and $BackupFilesToRemote)
    {
    mkdir $BackupDir
    Write-PLDebug -Message "Created Directory $DestinationDIR"
    }
if ($RollbackLast -or $Rollback)
    {
    $Test = Get-ChildItem -Path $BackupDir 
    $DeployDates = $test.name | Sort-Object -Descending -Unique
    if ($RollbackLast)
        {
        $SourceDIR = Join-Path $BackupDir $DeployDates[0]
        }
    else
        {
        $MessageTitle = 'Rollback Selection'
        $Messageprompt = 'Select Date to restore to?'
        [System.Management.Automation.Host.ChoiceDescription[]]$Options = @()
        $i = 1
        foreach ($Date in $DeployDates)
            {
            $DateEntry = "&$i $Date"
            $Options += New-Object System.Management.Automation.Host.ChoiceDescription $DateEntry, $Date
            $i++
            }
        $choice = $host.ui.PromptForChoice($title, $message, $options, [int](0))
        $SourceDIR = Join-Path $BackupDir $options[$choice].helpmessage


        }
     $oldString = "_$($options[$choice].helpmessage).BAD"
    }
else # Not rolling back
    {
     $oldString = "_$CopyDate.old"
    }

    $SourceTree = Get-ChildItem $SourceDIR -Recurse
    $RootDIR = $SourceDIR
    $RootLength = $RootDIR.Length

if (!$(Test-Path -Path $DestinationDIR))
    {
    mkdir $DestinationDIR | out-Null
    Write-PLDebug -Message "Created Directory $DestinationDIR"
    }



#endregion

    $Sourcefiles = @($SourceTree | Where-Object {$_.mode -ne 'd----'})


    foreach($file in $SourceFiles)
        {
        $RelDIRLength = $file.DirectoryName.Length - $RootDIR.Length
            # Get Length for Relative Directory Calculation
        $RelativeDIRPath = $file.DirectoryName.Substring($RootLength,$RelDIRLength)
            # Get actual Relative DIR Path by creating a substring
        $NewDIR = Join-Path $DestinationDIR $RelativeDIRPath
            #New Directory By Joining Destination with Relativepath
        $NewFile = Join-Path $NewDIR $file.name
            #New file by joining New DIR and file name
        $BackupFileName = $file.Name + $oldString
            #Backup file name file name + Date/time
        $BackupFilePath = Join-Path $("$BackupDir\$CopyDate") $RelativeDIRPath
            #Relative file path within the backup directory so we know where it is
        $exists = Test-Path -path $NewFile
            #IF the file exists or not

        if ($exists){
               if ($BackupFilesToRemote)
                    {
                    Write-PLVerbose -Message "Backing up $($file.name) to $BackupDir"
                    if (!$(Test-path -path $BackupFIlePath))
                    {mkdir $BackupFilePath | Out-Null}
                    Copy-Item $NewFile $BackupFilePath -Force -ErrorVariable MyError
                       if ($MyError -ne $null)
                            {
                            Write-PLInfo -Message "ERROR: Unable to Backup file $NewFile due to $($Myerror.exception)"
                            Write-Error -Message "ERROR: Unable to Backup file $NewFile due to $($Myerror.exception)"
                            continue
                            }
                    }
                else
                    {
                # New file exists Backup up Current copy and Copy new file
                Write-PLVerbose -Message "$NewFile already exists attempting to Rename file"
                try {Rename-Item -Path $NewFile -NewName $BackupFileName  -ErrorAction Stop -ErrorVariable MyError}
                catch [System.IO.IOException] 
                {
                $Userinput = Read-Host -Prompt "The file $BackupFileName Already exists do you wish to replace it? (Y,N)"
                  if ($Userinput.ToLower() -eq 'y')
                    {
                    Remove-Item $(join-path $newdir $BackupFileName) -Force
                    Rename-Item -Path $NewFile -NewName $BackupFileName  -ErrorAction SilentlyContinue -ErrorVariable MyError
                    }
                
                }

                if ($MyError -ne $null)
                    {
                    Write-PLInfo -Message "ERROR: Unable to rename file due to $($Myerror.exception)"
                    Write-Error -Message "ERROR: Unable to rename file due to $($Myerror.exception)"
                    continue
                    }
                Write-PLInfo -Message "Successfully Renamed $NewFile to $($file.Name + $oldString)"
                    }


                }
                else {
                    # New File does NOT Exists Just copy
                    Write-PLDebug -Message "$NewFile Does Not Exist Creating file"
                      }
                   
            Write-PLDebug -Message "Trying to copy $($file.FullName) to $NewFile"
            try{
            Copy-Item -Path $file.FullName -Destination $NewFile -ErrorVariable MyError -Force
            }
            catch [System.IO.DirectoryNotFoundException]
                {
                if ($CreateAllDirectories)
                    {
                    mkdir $NewDIR | Out-Null
                    Write-PLInfo "Flag to Create Directory $NewDIR"
                    Copy-Item -Path $file.FullName -Destination $NewFile -ErrorVariable MyError -Force
                    continue
                    }
                else
                    {
                      $Userinput = Read-Host -Prompt "Directory for $NewFile not found do you wish to create? (Y,N)"
                      if ($Userinput.ToLower() -eq 'y')
                        {
                        mkdir $NewDIR | Out-Null
                        Write-PLInfo "User Prompt to Create Directory $NewDIR"
                        Copy-Item -Path $file.FullName -Destination $NewFile -ErrorVariable MyError -Force
                        continue
                        }
                    }
                }
            If ($MyError -ne $null)
                {
                Write-PLInfo -Message "ERROR: Unable to copy $NewFile due to $($Myerror.exception)"
                Write-Error -Message "ERROR: Unable to copy $NewFile due to $($Myerror.exception)"
                continue
                }
            Write-PLInfo -Message "Successfully Copied $NewFile from $($file.fullname)"
            If ($Purge)
                {
                Write-PLDebug -Message "PURGE: Attempting to remove $($file.fullname)"
                Remove-Item -Path $file.FullName -ErrorVariable MyError
                If ($MyError -ne $null)
                    {
                    Write-PLInfo -Message "ERROR: Unable to Remove File Due to $($Myerror.exception)"
                    continue
                    }
                Write-PLDebug -Message "Successfully Deleted $($file.FullName)"
                }

    }
    #>

## END ##
Write-PLInfo -Message "Finished processing at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
}
