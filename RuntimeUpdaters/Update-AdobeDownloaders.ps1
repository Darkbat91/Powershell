#Scheduled Task to Update Adobe Downloaders
Import-Module BitsTransfer

$MSIURL = @()
$adobeauthtoken=## NEED TO ADD AUTH TOKEN
$DestinationPlugin = "##Destination##"
$DestinationAX = "##Destination"

$URLs = Invoke-WebRequest -Uri "https://www.adobe.com/products/flashplayer/distribution4.html?auth=$Adobeauthtoken" | select -expand links
$Urls  | ForEach-Object {if ($_.innerHtml -like "Download MSI*") {$MSIURL += $_.href}}

$SourceAX = $MSIURL[0]


#Invoke-WebRequest -uri $SourceAX -OutFile $DestinationAX
#(new-object System.Net.WebClient).Downloadfile($SourceAX, $DestinationAX)

$SourcePlugin = $MSIURL[1]


#Invoke-WebRequest -uri $SourcePlugin -OutFile $DestinationPlugin
#(new-object System.Net.WebClient).Downloadfile($SourcePlugin, $DestinationPlugin)

Start-BitsTransfer -Source $SourceAX, $SourcePlugin -Destination $DestinationAX, $DestinationPlugin
