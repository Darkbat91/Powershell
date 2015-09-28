function Get-NetStat
{
<#
.SYNOPSIS
    Powershell wrapper for netstat
.DESCRIPTION
    Returns an object with the current TCP and UDP connections using netstat and parsing the output
.INPUTS
    None
.OUTPUTS
    Returns Objects with all current connections to the terminal can be stored in a variable for other uses
.PARAMETER ResolveHostName
        Resolves All IP's to their proper host name
.PARAMETER ResolveProcessName    
        Resolves All PID's to the process Name
.PARAMETER All
        Returns TCP and UDP connections same as -a in netstat
.PARAMETER State
        Will filter results on only one state IE: SYN_SEND
.EXAMPLE
    Get-Netstat -All -ResolveProcessName
        Will return all TCP and UDP connections as well as resolve the PID to its process name for easy lookup
.NOTES
Base script is from online resource unknown Author

    Author: Micah
    Creation Date: 20150728
    Last Modified: 20150728
    Version: 1.2

-----------------------------------------------------------------------------------------------------------------
CHANGELOG
-----------------------------------------------------------------------------------------------------------------

    1.0 Script from online
    1.2 Adds All Paramaters for filtering as well as proper IPV6 Resolution, and UDP fork for removing the State

-----------------------------------------------------------------------------------------------------------------
TODO
-----------------------------------------------------------------------------------------------------------------
    Add Live monitoring
#>


### Params ###
param (
[switch]$ResolveHostname,
[switch]$ResolveProcessName,
[Alias("A")]
[switch]$All,
[ValidateSet("CLOSE_WAIT", "CLOSED", "ESTABLISHED","FIN_WAIT_1", "FIN_WAIT_2", "LAST_ACK", "LISTEN", "SYN_RECEIVED", "SYN_SEND", "TIMED_WAIT")]
$State="*"

)
    PROCESS
    {
        # Get the output of netstat
        if ($All)
        {
            if ($Resolvehostname) {$data = netstat -ao}
            else {$data = netstat -ano}
        }
        else
        {
            if ($Resolvehostname) {$data = netstat -o}
            else {$data = netstat -no}
        }

        # Keep only the line with the data (we remove the first lines)
        $data = $data[4..$data.count]
        
        # Each line need to be splitted and get rid of unnecessary spaces
        foreach ($line in $data)
        {
            # Get rid of the first whitespaces, at the beginning of the line
            $line = $line -replace '^\s+', ''
            
            # Split each property on whitespaces block
            $line = $line -split '\s+'
            
        $protocol = $line[0]

        #region IPV6 Fix
            # Fix for IP V6 on Local Address
            if ($line[1] -like '*`[*`]*')
                {
                    $line[1] -match "(\[[a-zA-Z0-9\:\%]*\])(\:)(\d*)" | Out-Null
                    $LocalAddressIP = $Matches[1]
                    $LocalAddressPort = $Matches[3]
                }
                else 
                {
                    $LocalAddressIP = ($line[1] -split ":")[0]
                    $LocalAddressPort = ($line[1] -split ":")[1]
                }

            if ($line[2] -like '*`[*`]*')
                {
                    $line[2] -match "(\[[a-zA-Z0-9\:\%]*\])(\:)(\d*)" | Out-Null
                    $ForeignAddressIP = $Matches[1]
                    $ForeignAddressPort = $Matches[3]
                }
                else 
                {
                    $ForeignAddressIP = ($line[2] -split ":")[0]
                    $ForeignAddressPort = ($line[2] -split ":")[1]
                }

        #endregion



            # Define the properties

            # if TCP allow the state field
        if ($protocol -eq "TCP")
        {
            $properties = @{
                Protocol = $protocol
                LocalAddressIP = $LocalAddressIP
                LocalAddressPort = $LocalAddressPort
                ForeignAddressIP = $ForeignAddressIP
                ForeignAddressPort = $ForeignAddressPort
                State = $line[3]
                Process = if ($ResolveProcessName){(Get-Process -id $line[4]).Name} else {$line[4]}
                }
        }
        #For UDP without a state
        elseif ($protocol -eq "UDP")

        {
                $properties = @{
                Protocol = $protocol
                LocalAddressIP = $LocalAddressIP
                LocalAddressPort = $LocalAddressPort
                ForeignAddressIP = $ForeignAddressIP
                ForeignAddressPort = $ForeignAddressPort
                Process = if ($ResolveProcessName){(Get-Process -id $line[3]).Name} else {$line[3]}
                }
        }
         
            
            # Output the current line
            if ($properties.State -like $State)
            {New-Object -TypeName PSObject -Property $properties}
        }
    }
}

export-modulemember -function Get-NetStat
