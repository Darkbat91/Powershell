Import-Module BitsTransfer

$DestinationDIR = #Desired Destination Directory

$URLs = Invoke-WebRequest -Uri "https://www.java.com/en/download/manual.jsp" | select -expand links
$Urls  | ForEach-Object {if ($_.innerHtml -like "Windows Offline") {$Source86Url = $_.href}}
$Urls  | ForEach-Object {if ($_.innerHtml -like "Windows Offline (64-bit)") {$Source64Url = $_.href}}
$Destination86 = "$DestinationDIR\Javainstall86.exe"
$Destination64 = "$DestinationDIR\Javainstall64.exe"


#$FileName = [System.IO.Path]::GetFileName((Get-RedirectedUrl $SourceURL))


#Invoke-WebRequest -Uri $SourceURL -OutFile $Destination
Start-BitsTransfer -Source $Source86Url, $Source64Url -Destination $Destination86, $Destination64
