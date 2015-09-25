#Borrowed function
Function Get-RedirectedUrl {

    Param (
        [Parameter(Mandatory=$true)]
        [String]$URL
    )

    $request = [System.Net.WebRequest]::Create($url)
    $request.AllowAutoRedirect=$false
    $response=$request.GetResponse()

    If ($response.StatusCode -eq "Found")
    {
        $response.GetResponseHeader("Location")
    }
}

$URLs = Invoke-WebRequest -Uri "https://www.java.com/en/download/manual.jsp" | select -expand links
$Urls  | ForEach-Object {if ($_.innerHtml -like "Windows Offline") {$SourceUrl = $_.href}}
$Destination = "C:\jreX86.exe"
$date = Get-Date -Format ddMMMyyyy
$emailTo = "email@company.com"
$emailFrom = "Help Desk<help@company.com>"

$FileName = [System.IO.Path]::GetFileName((Get-RedirectedUrl $SourceURL))



if ($SourceURL -ne $null)
{ Invoke-WebRequest -Uri $SourceURL -OutFile $Destination}
else
{
$subject = "Java Auto Update Failed $Date"
$message = "Java has changed their site and this script needs updated. It is located at <Script Location> Most likely line 19 will need updated with the new URL"
$PickupDirectory = "\\emailserver\C$\Program Files\Microsoft\Exchange Server\V14\TransportRoles\Pickup"
$Template = 
"To: $emailTo
From: $emailFrom
Subject: $subject

$message"

Add-Content -Path $($PickupDirectory + "\email.eml") -Value $Template
}
