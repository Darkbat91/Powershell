<#
.SYNOPSIS
    Generate Printer Count Report
.DESCRIPTION
    Queries all printers to pull their print counts for color and black and white, Requires the DLL file in same directory in order to work.
.INPUTS
    None
.OUTPUTS
    Log File and csv of counts stored in same directory as script 
.EXAMPLE
.PARAMETER
.NOTES
    Author: Micah
    Creation Date: 20150421
    Last Modified: 
    Version: 1

.CHANGELOG

.TODO
#>


### Configuration ###
# < Imports for usability >
Import-Module Powerlogger
Start-Logging -ScriptVersion "1"

### Variables ###
$PrinterCounts = @()
#Color Pages HP
$OIDColorHP = ".1.3.6.1.4.1.11.2.3.9.4.2.1.4.1.2.7"
#Total Pages 
$OIDTotalPages = ".1.3.6.1.2.1.43.10.2.1.4.1"
#Konica Copy Pages .1 is Copy .2 is print
$OIDColorCopyKonica = ".1.3.6.1.4.1.18334.1.1.1.5.7.2.2.1.5.2"
#Scan Fax color
$OIDScanFaxColorKonica = ".1.3.6.1.4.1.18334.1.1.1.5.7.2.3.1.11"

$Printers = Import-Clixml -Path D:\test\printers.xml

### Functions ###

function Invoke-SnmpWalk ([string]$sIP, $sOIDstart, [string]$Community = "public", [int]$UDPport = 161, [int]$TimeOut=3000) {
    [System.Reflection.Assembly]::LoadFile((Resolve-path D:\test\SharpSnmpLib.dll)) > $null
    # $sOIDstart
    # $TimeOut is in msec, 0 or -1 for infinite
 
    # Create OID object
    $oid = New-Object Lextm.SharpSnmpLib.ObjectIdentifier ($sOIDstart)
 
    # Create list for results
     $results = New-Object 'System.Collections.Generic.List[Lextm.SharpSnmpLib.Variable]'                         # PowerShell v3
 
    # Create endpoint for SNMP server
    $ip = [System.Net.IPAddress]::Parse($sIP)
    $svr = New-Object System.Net.IpEndPoint ($ip, 161)
 
    # Use SNMP v2 and walk mode WithinSubTree (as opposed to Default)
    $ver = [Lextm.SharpSnmpLib.VersionCode]::V2
    $walkMode = [Lextm.SharpSnmpLib.Messaging.WalkMode]::WithinSubtree
 
    # Perform SNMP Get
    try {
        [Lextm.SharpSnmpLib.Messaging.Messenger]::Walk($ver, $svr, $Community, $oid, $results, $TimeOut, $walkMode)
    } catch {
        Write-Host "SNMP Walk error: $_"
        Return $null
    }
 
    $res = @()
    foreach ($var in $results) {
        $line = "" | Select OID, Data
        $line.OID = $var.Id.ToString()
        $line.Data = $var.Data.ToString()
        $res += $line
    }
 
    $res
}
Write-PLDebug -Message "Loaded Functions"

### Script Body ###

$PrintersCount = @()
foreach ($Printer in $Printers){
    if ($Printer.PrinterManufacturer -eq "Konica Minolta")
        {
        $KonicaPrinter = $Printer
        $KonicaColorCopy = Invoke-SnmpWalk -sIP $Printer.PrinterIP -sOIDstart $OIDColorCopyKonica
            $KonicaPrinter | Add-Member NoteProperty -Name "ColorPages" -Value $([int]$KonicaColorCopy.data[0] + [int]$KonicaColorCopy.data[1])
        $KonicaColorScanfax = Invoke-SnmpWalk -sIP $Printer.PrinterIP -sOIDstart $OIDScanFaxColorKonica
            $KonicaPrinter.ColorPages = $($KonicaPrinter.ColorPages + $KonicaColorScanfax.data)

        $KonicaPrinter | Add-Member NoteProperty -Name "TotalPages" -Value $(Invoke-SnmpWalk -sIP $Printer.PrinterIP -sOIDstart $OIDTotalPages).data
        $PrintersCount += $KonicaPrinter
        }
    if ($Printer.PrinterManufacturer -eq "HP")
        {
        $HPPrinter = $Printer
        $HPPrinter | Add-Member NoteProperty -Name "ColorPages" -Value $(Invoke-SnmpWalk -sIP $Printer.PrinterIP -sOIDstart $OIDColorHP).data
        $HPPrinter | Add-Member NoteProperty -Name "TotalPages" -Value $(Invoke-SnmpWalk -sIP $Printer.PrinterIP -sOIDstart $OIDTotalPages).data
        $PrintersCount += $HPPrinter 
        }

}


## END ##
Write-PLInfo -Message "Finished processing at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
