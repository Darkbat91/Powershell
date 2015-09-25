#Update Silverlight installer

#region Declare Variables
$7zipPath = "D:\7z"
$Temp = "D:\Silverlight.exe"
# Temp file to do extraction gets deleted at end
$FileDestination = "D:\Silverlight"
#Root of where files will be located
$SourceURL = "http://www.microsoft.com/getsilverlight/handlers/getsilverlight.ashx"
#URL of silverlight
#endregion



Invoke-WebRequest -Uri $SourceURL -OutFile $Temp -UserAgent 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:40.0) Gecko/20100101 Firefox/40.0'
# Agent string is required or file will not download due to microsoft check

start -wait $7zipPath\7z.exe  -Args "e $Temp -o$FileDestination -y"
#Extracts the File into the File Destination

#msiexec /i silverlight.msi /log D:\Silverlight.log /qn
#Install of Silverlight from MSI file
#NOTE: throws a 1638 if it is already installed

del $Temp
