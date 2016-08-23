function Get-VersionCheck
{
<#
.SYNOPSIS
	Checks Two Versions against each other
.DESCRIPTION
	Allows comparison of Version numbers that have identifiers
    Returns True if the Version is Greater than the Comparison
.PARAMETER $username
	
.EXAMPLE
	Get-AdUserLastLogon -UserName DoeJ
	
.NOTES	
    Author: Micah
    Creation Date: 20160818
    Last Modified: 20160818
    Version: 1.0.0

-----------------------------------------------------------------------------------------------------------------
CHANGELOG
-----------------------------------------------------------------------------------------------------------------
    1.0.0 Initial Release
	
	#>
param(
[string][Parameter(Mandatory=$true)]
$VersionNumber,
[string][Parameter(Mandatory=$true)]
$comparisonNumber,
[string][Parameter(Mandatory=$false)]
$versionIdentifier = '.',
[switch]$forceSamelength)

#split the version numbers into the sub numbers splitting on the version identifier
$versionarray = $VersionNumber.split($versionIdentifier)
$comparisonarray = $comparisonNumber.split($versionIdentifier)

# If the arrays do not have the same number of itterations than we can only compare the ones we have
if($versionarray.Count -ne $comparisonarray.Count) 
{
    #If set to force same length then throw error
    if($forceSamelength.IsPresent)
        {
        throw "Version numbers provided are not equal in build number"
        }
}

#If the Arrays are not equal we need to use the one with the most itterations
if($versionarray.Count -gt $comparisonarray.count)
    {
    $checks = $versionarray.Count
    $unmatched = $true
    }
else
    {
    $checks = $comparisonarray.Count
    $unmatched = $false
    }


#Loop through each item in the array
for($count = 0; $count -lt $checks; $count++)
{
if($versionarray[$count] -gt $comparisonarray[$count])
    {
    # If the array element is all 0's and this is the last element of an unmached set
    if($versionarray[$count] -match '0+' -and $count -eq ($checks - 1) -and $unmatched)
        {
        return $false
        }
    
    #If we have less digits in one build then we can assume it is lesser
    if($($versionarray[$count].Length) -lt $($comparisonarray[$count].Length))
    {
    return $false
    }
    # If the version is greater at any 1 then it is true
    return $true
    }

#If we have more digits in one build then we can assume it is greater
if($($versionarray[$count].Length) -gt $($comparisonarray[$count].Length))
    {
    return $true
    }
}

return $false


}

