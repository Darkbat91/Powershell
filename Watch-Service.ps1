<#
.SYNOPSIS
	Queries service status
.DESCRIPTION
	Checks status of service and if not running starts the service

.NOTES
Author: Micah
Creation Date: 13AUG2014
Last Modified: 17APR2015
Version: 1.5

.CHANGELOG

1.5
    - Created xml export so that email will only fire once an hour
    - Changed Email format so that it does not rely on SMTP being open
    - Added start command paramater so it can be used to only monitor services

.TODO
    - Create Variable so that notifications can be specified at a certain interval and not just defaulted to 1 hour

	#>



function Watch-Service{
param($ServiceName, $Start=$true)

#Get time and date in proper format
$time = Get-Date -Format yyyyMMdd-mmss

# Create service notification object and Fill in if there is one already existing
if (Test-Path "$env:ALLUSERSPROFILE\TempWatch")
{
$ServiceNotification = Import-Clixml -Path "$env:ALLUSERSPROFILE\TempWatch"
}
else
{
$servicenotification = New-Object PSObject
$servicenotification | Add-Member NoteProperty -Name "Sent" -Value $false
$servicenotification | Add-Member NoteProperty -Name "time" -Value $(get-date)
}
if ((New-TimeSpan -End $servicenotification.time).Hours -gt 1) {$servicenotification.Sent = $false}

$arrService = Get-Service -Name $ServiceName
if ($arrService.Status -eq "Stopped"){
    if ($Start -eq $true)
        {Start-Service $ServiceName
        if ($LASTEXITCODE -eq 0){
         Mailer -subject "($ServiceName) started." -message "Service $ServiceName had to be started at $time"
         }
         else{Mailer -subject "($ServiceName) Unable to be started." -message "Service $ServiceName was UNABLE to be started at $time"}
        }
    else
        { 
         if ($ServiceNotification.Sent -eq $false)
         {
         Mailer -subject "($ServiceName) Not running." -message "Service $ServiceName is stopped as of $time. I am NOT configured to start it. You can start it manually on $env:COMPUTERNAME"
         $ServiceNotification.sent = $true
         $servicenotification.time = Get-Date
         }
         
        }
} 
$ServiceNotification | Export-Clixml -Path "$env:ALLUSERSPROFILE\TempWatch"
}

Function Mailer ($emailTo="email@company.com", $message, $subject)
{
$emailFrom = "help@company.com"
$PickupDirectory = "\\mailserver\C$\Program Files\Microsoft\Exchange Server\V14\TransportRoles\Pickup"
$Template = 
"To: $emailTo
From: $emailFrom
Subject: $subject

$message"
Add-Content -Path $($PickupDirectory + "\email.eml") -Value $Template
}

Watch-Service -ServiceName "service" -Start $false
