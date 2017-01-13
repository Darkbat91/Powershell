function Get-ObjectChoice
{
<#
.Synopsis
   Allows you to make a selection from a list of Items
.DESCRIPTION
   Takes an array and will output the selection of the user in the array
.NOTES	
    Author: MicahJ
    Creation Date: 20170113
    Last Modified: 20170113
    Version: 1.0.0

-----------------------------------------------------------------------------------------------------------------
CHANGELOG
-----------------------------------------------------------------------------------------------------------------
    1.0.0 Initial Release
       
#>
    [CmdletBinding()]
    Param
    (
        # Object that selection will be made from
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [array]$object,
        # Prompt for user
        $prompt = "Please Make a Selection."
    )
        $count = 0
foreach ($item in $object)
    {
        Write-Host "$count - $item" 
        $count++
    }
$choice = ""
do {
    $choice = read-host "$prompt (q to quit)"
    }
while ($choice -gt $object.Count -and $choice -ne 'q' )
if($choice -eq 'q')
    {
    return
    }
return $object[[int]$choice]

}
