#Scheduled Task to Update Adobe Downloaders
Import-Module BitsTransfer

$MSIURL = @()
$DestinationPlugin = "##Destination##"
$DestinationAX = "##Destination"

$URLs = Invoke-WebRequest -Uri "https://www.adobe.com/products/flashplayer/distribution3.html" | select -expand links
$Urls  | ForEach-Object {if ($_.innerHtml -like "Download MSI*") {$MSIURL += $_.href}}

$SourceAX = $MSIURL[0]


#Invoke-WebRequest -uri $SourceAX -OutFile $DestinationAX
#(new-object System.Net.WebClient).Downloadfile($SourceAX, $DestinationAX)

$SourcePlugin = $MSIURL[1]


#Invoke-WebRequest -uri $SourcePlugin -OutFile $DestinationPlugin
#(new-object System.Net.WebClient).Downloadfile($SourcePlugin, $DestinationPlugin)

Start-BitsTransfer -Source $SourceAX, $SourcePlugin -Destination $DestinationAX, $DestinationPlugin
