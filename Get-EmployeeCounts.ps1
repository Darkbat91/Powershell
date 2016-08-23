function Get-UniqueCounts
{
param(
$InputData,
$values
)
$counts = @{}
$allunique = @{}

#region Create core Counts
# For each heading within all of the Values provided
foreach($value in $values)
    {
    # Get the unique values for that heading
    $uniqueValues = $InputData.$value | Sort-Object -Descending -Unique 
    #Go through each of the unique Values for the heading
    Foreach ($uniqueValue in $uniqueValues)
        {
        # Add the number for each of the Unique Values
        $counts.$uniqueValue = ($InputData | Where-Object {$_.$Value -eq $uniqueValue}).count
        Write-Host $uniqueValue - $counts.$uniqueValue
        # If we recieved nothing then return 1 as it wasnt an array
        if ($counts.$uniqueValue -eq $null)
            {$counts.$uniqueValue = 1}
        }

    }
#endregion

return $counts
}
