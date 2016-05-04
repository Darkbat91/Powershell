function Wait-RDPConnection
{
    param ([string]$ComputerName
    ,[int]$Port='3389',
    [alias('w')]
    [switch]$WaitForReboot,
    [alias('q')]
    [switch]$Quiet)

$pingOk = $false
$PortOK = $false

if ($WaitForReboot.IsPresent){
    if (!$Quiet.IsPresent){ write-host "Waiting for $ComputerName to reboot... " -nonewline }
    do {
        $pingOk = Test-Connection $ComputerName -quiet
        if ($pingOk) {
            if (!$Quiet.IsPresent){ write-host "." -nonewline -fore red}
            }
        } until (!$pingOk)
    if (!$Quiet.IsPresent){ Write-Host "`n$ComputerName is down."}
    }
 
 if (!$Quiet.IsPresent){ write-host "`nPinging $ComputerName ... " -nonewline}

    do{
        $pingOk = Test-Connection $ComputerName -erroraction silentlyContinue  
        if ($pingOk){
            if (!$Quiet.IsPresent){ write-host "`n$ComputerName replied."}
            }
        else{
            write-host "." -nonewline -fore red
            #too slow to add sleep
            #Start-Sleep  -milliseconds 500
            }
        } until ($pingOk)

       if (!$Quiet.IsPresent){  write-host "`nWaiting for port $Port ... " -nonewline}
        
        do{
            $portOk = wait-ComputerPort -ComputerName $ComputerName -Port $Port
            if ($portOk){
                if (!$Quiet.IsPresent){ Write-Host "`nPort $Port has opened"}
                }
            else{
                #Start-Sleep -milliseconds 500
                if (!$Quiet.IsPresent){ Write-Host "." -nonewline -fore red}
                }
            }until ($portOk)

if (!$Quiet.IsPresent){ Write-Host "`n$Computername is ready for RDP connection"}

[string]$strCommand = $ComputerName + ':' + $Port
mstsc.exe /v:$strCommand
}

export-modulemember -function Wait-RDPConnection
