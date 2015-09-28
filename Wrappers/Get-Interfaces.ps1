function Get-Interfaces
{
<#
.SYNOPSIS
    Wrapper function for Netsh get interfaces
.DESCRIPTION
    Returns computer interfaces and attributes
.INPUTS
    None
.OUTPUTS
    Interface Object
.NOTES
    Author: Micah
    Creation Date: 20150728
    Last Modified: 20150728
    Version: 1.0

-----------------------------------------------------------------------------------------------------------------
CHANGELOG
-----------------------------------------------------------------------------------------------------------------
    1.0 Initial Release
#>
### Script Body ###
$data = netsh interface show interface

        # Keep only the line with the data (we remove the first lines)
        $data = $data[3..$($data.count-2)]

foreach ($line in $data)
        {
        $line -match '(\w*)(\s*)(\w*)(\s*)(\w*)(\s*)([\d\w\s]*)' | Out-Null
        $properties = @{
            AdminState = $Matches[1]
            State = $Matches[3]
            Type = $Matches[5]
            InterfaceName= $Matches[7]
            }
        New-Object -TypeName PSObject -Property $properties
        }
}

export-modulemember -function Get-interfaces
