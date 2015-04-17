<#
.SYNOPSIS
    <Overview of script>
.DESCRIPTION
    <Brief description of script>
.INPUTS
    <Inputs if any, otherwise state None>
.OUTPUTS
    <Outputs if any, otherwise state None - example: Log file stored in C:\Windows\Temp\<name>.log> 
.EXAMPLE
.PARAMETER
.NOTES
    Author: Micah
    Creation Date: 
    Last Modified: 
    Version: 1

.CHANGELOG

.TODO
#>

### Params ###
# < Paramaters that are passed to the function >

### Configuration ###
# < Imports for usability >
Import-Module Powerlogger
Start-Logging -ScriptVersion "1"

### Functions ###
. C:\USend-MMail.ps1
    #Send-MMail -message "Example"

### Script Body ###



## END ##
Write-PLInfo -Message "Finished processing at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
