<#
.SYNOPSIS
    Send Emails 
.DESCRIPTION
    Creates an Email file in the pickup directory of the exchange server
.INPUTS
    Text for email message
.OUTPUTS
    .eml file in the pickup directory of the exchange server
.EXAMPLE
    Send-MMail -message "THis is an example Email
.PARAMETER emailTO
    Who the email is being sent to
.PARAMETER message
    The body of the email
.PARAMETER msubject
    The subjecet of the email
.PARAMETER FromAlias
    All emails come from the helpdesk the from alias just puts a name with the email address used to distinguish emails from different scripts
.NOTES
    Author: Micah
    Creation Date: 17APR2015
    Last Modified: 17APR2015
    Version: 1

.CHANGELOG

.TODO
#>

Function Send-MMail 
{

### Params ###
param(
[Parameter(Mandatory=$true)]$emailTo,
[Parameter(Mandatory=$true)]$message, 
[Parameter(Mandatory=$false)]$subject="Automated email", 
[Parameter(Mandatory=$false)]$FromAlias="Help Desk")

$PickupDirectory = "\\server\C$\Program Files\Microsoft\Exchange Server\V14\TransportRoles\Pickup"
$emailFrom = "$FromAlias<help@company.com>"
$Template = 
"To: $emailTo
From: $emailFrom
Subject: $subject

$message"
### Configuration ###
# < Imports for usability >
#Start-Logging -ScriptVersion "1"

### Functions ###

### Script Body ###

Add-Content -Path $($PickupDirectory + "\email.eml") -Value $Template
}

## END ##
#Write-PLInfo -Message "Finished processing at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
