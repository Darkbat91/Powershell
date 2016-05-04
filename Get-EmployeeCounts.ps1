function Get-EmployeeCounts
{
param(
$inputData,
$values,
[int]$comparisons=1,
[switch]$onlyTrue,
[switch]$oneobject,
[string]$Prefix = '',
[string]$suffix = ''
)
$Core = @{}
$counts = @{}
$allunique = @{}
$valuecount = $values.count

#region Create core Counts
# For each heading within all of the Values provided
foreach($value in $values) 
    {
    $valueBoolean = $false
    $valueName="$prefix$value$suffix"
    # Get the unique values for that heading
    $uniqueValues = $inputData.$value | Sort-Object -Descending -Unique 

    if ($uniqueValues -eq ($true, $false) -or $uniqueValues -eq ($false, $true))
        {
        # if only uniqe values are true and false it is a boolean
            # have to put in both ways incase more true or more false
        $valueBoolean = $true
        
        }
    if($valueBoolean -and $onlyTrue.IsPresent)
        {
        $uniqueValues = $value
        $allunique.$value = $value
        }
    else
        {
        #Add all of the Unique values to the hash table to later itteration
        $allunique.$value = $uniqueValues
        }

    #Go through each of the unique Values for the heading
    Foreach ($uniqueValue in $uniqueValues)
        {
        $uniqueValueName = "$Prefix$uniqueValue$suffix"
        if ($valueBoolean -and $onlyTrue.IsPresent)
            {# if asked for only true and Value is a boolean
            $Core.$valueName = ($inputData | Where-Object {$_.$Value -eq $true}).count
            }
        else
            {
            $Core.$uniqueValueName = ($inputData | Where-Object {$_.$Value -eq $uniqueValue}).count
            }

        if ($Core.$uniqueValue -eq $null -and ($inputData | Where-Object {$_.$Value -eq $uniqueValue}) -ne $null)
            {$Core.$uniqueValue = 1}
        elseif ($Core.$uniqueValue -eq $null)
            {$Core.$uniqueValue = 0}



<#        if ($valueBoolean -and $onlyTrue.IsPresent)
            {
            $core.Remove($true)
            $core.Remove($false)
            }#>
        }

    }
#endregion

if ($values.count -gt 1)
{
#region SubValues

Foreach($UniqueVal in $allunique.($values[0]))
    {
    if ($UniqueVal -eq ($true, $false) -or $UniqueVal -eq ($false, $true))
        {
        # if only uniqe values are true and false it is a boolean
            # have to put in both ways incase more true or more false
        $UniqueValBoolean = $true
        }

    foreach($Subval in $allunique.($values[1]))
        {
        if ($Subval -eq ($true, $false) -or $Subval -eq ($false, $true))
            {
            # if only uniqe values are true and false it is a boolean
                # have to put in both ways incase more true or more false
            $SubvalBoolean = $true
            }

        $CurrentValue = "$UniqueVal - $subval"
        if ($SubvalBoolean -and $onlyTrue.IsPresent -and $UniqueValBoolean)
            {
            $TempValue = ($inputData | Where-Object {$_.($Values[0]) -eq $true -and $_.($Values[1]) -eq $true})
            $counts.$CurrentValue = $TempValue.count
            }
        elseif ($SubvalBoolean -and $onlyTrue.IsPresent)
            {
            $TempValue = ($inputData | Where-Object {$_.($Values[0]) -eq $UniqueVal -and $_.($Values[1]) -eq $true})
            $counts.$CurrentValue = $TempValue.count
            }
        elseif ($UniqueValBoolean -and $onlyTrue.IsPresent)
            {
            $TempValue = ($inputData | Where-Object {$_.($Values[0]) -eq $true -and $_.($Values[1]) -eq $true})
            $counts.$CurrentValue = $TempValue.count
            }
        else
            {
            $TempValue = ($inputData | Where-Object {$_.($Values[0]) -eq $UniqueVal -and $_.($Values[1]) -eq $Subval})
            $counts.$CurrentValue = $TempValue.count
            }
        if ($counts.$CurrentValue -eq $null -and $TempValue -ne $null)
            {$counts.$CurrentValue = 1}
        elseif ($counts.$CurrentValue -eq $null)
            {$counts.$CurrentValue = 0}
        }
    }
    
#endregion
}
if($oneobject.IsPresent)
    {
    return $core + $counts
    }

return $core, $counts
}
