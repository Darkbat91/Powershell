$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Get-VersionCheck - Regular" {

    It "Work with Single Values" {
        Get-VersionCheck -VersionNumber '123' -comparisonNumber '122' | Should Be $True
        Get-VersionCheck -VersionNumber '122' -comparisonNumber '123' | Should Be $false
    }
    It "Work with two values" {
        Get-VersionCheck -VersionNumber '123.50' -comparisonNumber '122.30' | Should Be $True
        Get-VersionCheck -VersionNumber '120.30' -comparisonNumber '122.50' | Should Be $false
    }

    It "Work with different length Values" {
        Get-VersionCheck -VersionNumber '123.1010' -comparisonNumber '123.910' | Should Be $True
        Get-VersionCheck -VersionNumber '123.910' -comparisonNumber '123.1010' | Should Be $false
    }


}

Describe "Get-VersionCheck - Zero handling" {
    It "Count not having an incrament as being lower if same to that step" {
        Get-VersionCheck -VersionNumber '122.11' -comparisonNumber '122' | Should Be $true
        Get-VersionCheck -VersionNumber '122' -comparisonNumber '122.11' | Should Be $false
    }

    It "Ignore Zeros as the last Version incrament" {
        Get-VersionCheck -VersionNumber '122.00' -comparisonNumber '122' | Should Be $false
        Get-VersionCheck -VersionNumber '122' -comparisonNumber '122.00' | Should Be $false
    }

    It "Not skew results with zeros in middle" {
        Get-VersionCheck -VersionNumber '122.00.2' -comparisonNumber '122.00.1' | Should Be $true
        Get-VersionCheck -VersionNumber '122.00.1' -comparisonNumber '122.00.1' | Should Be $false
    }

}

