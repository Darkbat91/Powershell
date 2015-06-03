<#
.SYNOPSIS
	Runs a Report to pull all AD Users with Accounts expiring or expired
.DESCRIPTION
	Sends Reminder emails to all users with Accounts expiring within 14 days or will create a CSV file with users who have passwords already expired over 100 days
.PARAMETER $AccountAgeReport
	Changes the Use from sending emails to just creating a CSV file
.EXAMPLE
	Get-AdExpiringAccounts -AccountAgeReport=$true
.EXAMPLE
	Get-AdExpiringPasswords -testing=$true
        Will only send email to administrator email
	
.NOTES	
AUTHOR:   Micah
DATE:     2015-06-03
Version:  1.0
TODO:     Clean up script from transfer
	#>


param($MaximumDaysLeft = 15,
      $MinimumDaysLeft = 0,
      $MaximumAge = 100,
      $Path = ".\AccountAgeReport.csv",
      $AccountAgeReport=$False,
      $testing = $True,
      $AdministratorEmail = "Your Email")



## ALL USERS WITH A Expiration date AND EMAIL ##
$Users = Get-ADUser -filter {Enabled -eq $True -and Mail -like "*" -and AccountExpires -ne "9223372036854775807" -and AccountExpires -ne "0"} -Properties AccountExpires, mail, DisplayName | | Where-Object {$_.DisplayName -ne $null}

##  CREATES DAYS LEFT OBJECT WITH DAYS UNTIL ACCOUNT LOCKOUT
$Users | ForEach-Object {Add-member -InputObject $_ @{daysleft=(New-TimeSpan -End ([datetime]::FromFileTime($_.AccountExpires)))} -Force}

Function CreateMessage()
{
    param($DisplayName = "",
          $ExpirationDate,
          $DaysLeft)
    $MessageTemplate = @"
<html>
	<body style="font-family:times new roman;font-size:16">
		<p>
			<b style="font-size:18"><i><u>$DisplayName,</u></i></b>
		</p>
		<p>
			This is a friendly reminder that your password is set to expire on <b style="color:red"><i><u>$ExpirationDate</u></i></b>. 
			If your password is not changed in the next <b style="color:red"><i><u>$DaysLeft</u></i></b> days, your access to IT 
			resources ( email, OWA, etc….) will be restricted until your password has been reset.
		</p>
		<p>
			For instructions on resetting your password via the Outlook
			Web Access ( OWA ) interface please refer to the attached instructions
		</p>
		<p>
			**********************************************************************<br/>
			THIS IS A SYSTEM GENERATED EMAIL MESSAGE. PLEASE DO NOT RESPOND       <br/>
			**********************************************************************<br/>
		</p>
	</body>

</html>
"@
    return $MessageTemplate
}

Function SendEmail()
{
    param($From = "!",
          $To = "!",
          $Subject = "!",
          $HTMLMessage = "<html><body>Test</body></html>",
          $TextMessage = "",
          $SMTPServer = "",
          $AttachmentPath = "",
          $PickupDirectory = "!")
          
    $MailMessage = New-Object System.Net.Mail.MailMessage
    $SMTPClient = New-Object System.Net.Mail.SMTPClient
    
    
    $MailMessage.To.Add("$To")
    $MailMessage.From = "$From"
    $MailMessage.Subject = "$Subject"
    $MailMessage.Body = $HTMLMessage
    $MailMessage.IsBodyHTML = $true
    If($AttachmentPath -ne "")
    {
        $Attachment = New-Object System.Net.Mail.Attachment("$CurrentPath" + "\PasswordResetInstructions.docx")
        $MailMessage.Attachments.Add($Attachment)
    }
    $SMTPClient.PickupDirectoryLocation = $PickupDirectory
    $SMTPClient.DeliveryMethod = "SpecifiedPickupDirectory"
    
    $SMTPClient.Send($MailMessage)
    
}

ForEach($User in $Users)
{
If(($User.daysleft.Days -ge $MinimumDaysLeft) -and ($User.daysleft.Days -le $MaximumDaysLeft) -and ($AccountAgeReport = $false)){
        $Display = "$($user.GivenName) $($user.Surname)"
        $DaysRemaining = $User.daysleft.Days-1
        $Expiration = ([datetime]::Today).AddDays($DaysRemaining)
        $Message = CreateMessage -DisplayName $Display -ExpirationDate $($Expiration.ToShortDateString()) -DaysLeft $DaysRemaining
        if ($testing -eq $true){$Email = $AdministratorEmail}
        else {$Email = $User.mail}
        $Subject = "Reminder: You must reset your password by $($Expiration.ToShortDateString())"
        Write-Host """$Display"", $($User.SamAccountName), $DaysRemaining"
        SendEmail -To $Email -Subject $Subject -HTMLMessage $Message -AttachmentPath $AttachmentPath
}
elseif(($user.daysleft.Days -lt 0) -and $AccountAgeReport -eq $True){
    Add-Content -Path $Path -Value """Display Name"",""Username"",""Password Age"""
    ForEach($User in $Users)
    {
        $UserName = $User.samaccountname
        $PWDAge = $user.daysleft.Days
        If($PWDAge -gt $MaximumAge)
        {
            $DisplayName = $User.displayname
            $OutputString = """$DisplayName"",""$UserName"",""$PWDAge"""
            Add-Content -Path $Path -Value $OutputString
        }
    }


}


}




