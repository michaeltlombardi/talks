$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. $here\Get-AgedAccounts.ps1
. $here\Get-DisabledAccounts.ps1


Describe "Update-InactiveOrStaleADAccounts.ps1" {
  Context "Default behavior" {
    Mock Get-Content { "Excepted" }
    Mock Get-AgedAccounts {
      ForEach ($Instance in 1..4) {
        [PSCustomObject]@{
          DistinguishedName = (New-Guid).Guid
        }
      }
      [PSCustomObject]@{
        DistinguishedName = "Excepted"
      }
    }
    Mock Get-DisabledAccounts {
      ForEach ($Instance in 1..4) {
        [PSCustomObject]@{
          DistinguishedName = (New-Guid).Guid
        }
      }
      [PSCustomObject]@{
        DistinguishedName = "Excepted"
      }
    }
    Function Disable-ADAccount () {}
    Mock Disable-ADAccount {}
    Function Remove-ADObject () {}
    Mock Remove-ADObject
    Mock Export-Csv
    Context "When attempting to retrieve accounts to disable" {
      BeforeAll { & $here\$sut }
      It "Will look for user accounts which have not been logged into for 60 days" {
        Assert-MockCalled Get-AgedAccounts -ParameterFilter {
          $AccountType -eq 'User' -and
          $AgedAccountThreshold -eq 60
        }
      }
      It "Will look for user accounts which are older than 21 days" {
        Assert-MockCalled Get-AgedAccounts -ParameterFilter {
          $AccountType -eq 'User' -and
          $NewAccountThreshold -eq 21
        }
      }
      It "Will look for computer accounts which have not been logged into for 45 days" {
        Assert-MockCalled Get-AgedAccounts -ParameterFilter {
          $AccountType -eq 'Computer' -and
          $AgedAccountThreshold -eq 45
        }
      }
      It "Will look for computer accounts which are older than 14 days" {
        Assert-MockCalled Get-AgedAccounts -ParameterFilter {
          $AccountType -eq 'Computer' -and
          $NewAccountThreshold -eq 14
        }
      }
    }
    Context "When attempting to retrieve accounts to delete" {
      BeforeAll { & $here\$sut }
      It "Will NOT look for user accounts at all" {
        Assert-MockCalled Get-DisabledAccounts -Exactly 0 -ParameterFilter {
          $AccountType -eq 'User'
        }
      }
      It "Will look for computer accounts disabled for at least 183 days" {
        Assert-MockCalled Get-DisabledAccounts -ParameterFilter {
          $AccountType -eq 'Computer' -and
          $LastModifiedThreshold -eq 183
        }
      }
    }
    Context "When disabling aged accounts" {
      BeforeAll { & $here\$sut }
      It "Attempts to disable each discovered account unless excepted" {
        Assert-MockCalled Disable-ADAccount -Exactly 8
      }
      It "Writes the results to a CSV for all accounts discovered" {
        Assert-MockCalled Export-Csv -Exactly 10 -ParameterFilter {
          $Path -match "disabled accounts\.csv"
        }
      }
    }
    Context "When deleting inactive accounts" {
      BeforeAll { & $here\$sut }
      It "Attempts to delete each discovered account unless excepted" {
        Assert-MockCalled Remove-ADObject -Exactly 4
      }
      It "Writes the results to a CSV for all accounts discovered" {
        Assert-MockCalled Export-Csv -Exactly 5 -ParameterFilter {
          $Path -match "-deleted accounts\.csv"
        }
      }
    }
  }
  Context "Targeting an alternate DC" {
    Mock Get-Content { "Excepted" }
    Mock Get-AgedAccounts {
      ForEach ($Instance in 1..4) {
        [PSCustomObject]@{
          DistinguishedName = (New-Guid).Guid
        }
      }
      [PSCustomObject]@{
        DistinguishedName = "Excepted"
      }
    }
    Mock Get-DisabledAccounts {
      ForEach ($Instance in 1..4) {
        [PSCustomObject]@{
          DistinguishedName = (New-Guid).Guid
        }
      }
      [PSCustomObject]@{
        DistinguishedName = "Excepted"
      }
    }
    Function Disable-ADAccount ($Server) {}
    Mock Disable-ADAccount {}
    Function Remove-ADObject ($Server) {}
    Mock Remove-ADObject
    Mock Export-Csv
    Context "When disabling aged accounts" {
      BeforeAll { & $here\$sut -Server DC03 }
      It "Attempts to disable accounts by pointing at the specified DC" {
        Assert-MockCalled Disable-ADAccount -Exactly 8 -ParameterFilter {
          $Server -eq 'DC03'
        }
      }
    }
    Context "When deleting inactive accounts" {
      BeforeAll { & $here\$sut -Server DC03 }
      It "Attempts to delete each discovered account unless excepted" {
        Assert-MockCalled Remove-ADObject -Exactly 4 -ParameterFilter {
          $Server -eq 'DC03'
        }
      }
    }
  }
  Context "Providing an alternate exceptions list" {
    Mock Get-Content { "Excepted" }
    Mock Get-AgedAccounts {
      ForEach ($Instance in 1..4) {
        [PSCustomObject]@{
          DistinguishedName = (New-Guid).Guid
        }
      }
      [PSCustomObject]@{
        DistinguishedName = "Excepted"
      }
      [PSCustomObject]@{
        DistinguishedName = "SpecifiedExcepted"
      }
    }
    Mock Get-DisabledAccounts {
      ForEach ($Instance in 1..4) {
        [PSCustomObject]@{
          DistinguishedName = (New-Guid).Guid
        }
      }
      [PSCustomObject]@{
        DistinguishedName = "Excepted"
      }
      [PSCustomObject]@{
        DistinguishedName = "SpecifiedExcepted"
      }
    }
    Function Disable-ADAccount ($Identity, $Server) {}
    Mock Disable-ADAccount {}
    Function Remove-ADObject ($Identity, $Server) {}
    Mock Remove-ADObject
    Mock Export-Csv
    Context "When disabling aged accounts" {
      BeforeAll { & $here\$sut -NamedExceptions @("SpecifiedExcepted") }
      It "Attempts to disable each discovered account unless excepted" {
        Assert-MockCalled Disable-ADAccount -Exactly 10
        Assert-MockCalled Disable-ADAccount -Exactly 2 -ParameterFilter {
          $Identity -eq "Excepted"
        }
        Assert-MockCalled Disable-ADAccount -Exactly 0 -ParameterFilter {
          $Identity -eq "SpecifiedExcepted"
        }
      }
    }
    Context "When deleting inactive accounts" {
      BeforeAll { & $here\$sut -NamedExceptions @("SpecifiedExcepted") }
      It "Attempts to delete each discovered account unless excepted" {
        Assert-MockCalled Remove-ADObject -Exactly 5
        Assert-MockCalled Remove-ADObject -Exactly 1 -ParameterFilter {
          $Identity -eq "Excepted"
        }
        Assert-MockCalled Remove-ADObject -Exactly 0 -ParameterFilter {
          $Identity -eq "SpecifiedExcepted"
        }
      }
    }
  }
}
