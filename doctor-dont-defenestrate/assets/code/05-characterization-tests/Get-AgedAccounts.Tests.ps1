$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"
Function Get-ADUser{
  [cmdletbinding()]
  Param(
    $Filter,
    $Properties,
    $Server
  )
}
Function Get-ADComputer ($Filter, $Properties, $Server) {}
Describe "Get-AgedAccounts" {

  Context "Initalization" {
    Mock Get-ADUser {}
    Mock Get-ADComputer {}
    Mock Get-Date { Get-Date }

    BeforeAll {
      Write-Warning (Get-Command Get-ADUser).Definition
      Get-AgedAccounts -AccountType User -AgedAccountThreshold 10 -NewAccountThreshold 5
    }

    It "Retrieves the date twice for thresholds" {
      Assert-MockCalled Get-ADUser -Exactly 1
      Assert-MockCalled Get-Date -Exactly 2
    }
  }
  # Context "Retrieving User Accounts" {
  #   Function Get-ADUser ($Filter, $Properties, $Server) {}
  #   Mock Get-ADUser {
  #     # $Date = Get-Date
  #     # $Users = New-Object System.Collections.Arraylist
  #     # $ConvertedFilter = $Filter.ToString()
  #     # $Properties = @(
  #     #   @('\(enabled',            '($$_.enabled'),
  #     #   @('PasswordNeverExpires', '$$_.PasswordNeverExpires'),
  #     #   @(' WhenCreated',         ' $$_.WhenCreated'),
  #     #   @('samAccountType',       '$$_.samAccountType'),
  #     #   @('\(LastLogonDate',      '($$_.LastLogonDate')
  #     # )
  #     # foreach ($Property in $Properties) {
  #     #   $ConvertedFilter = $ConvertedFilter -replace $Property[0], $Property[1]
  #     # }
  #     # for ($i = 0; $i -le 10; $i++) {
  #     #   [void]$Users.Add([PSCustomObject]@{
  #     #     distinguishedName = (New-Guid).Guid
  #     #     samAccountName    = "Username$i"
  #     #     enabled           = $true
  #     #     PasswordNeverExpires = $false
  #     #     lastLogonDate     = $Date.AddDays((-55 - $i))
  #     #     whenCreated       = $Date.AddDays((-14 - $i))
  #     #     passWordLastSet   = $Date.AddDays(-10)
  #     #     whenChanged       = $Date.AddDays(-10)
  #     #     objectClass       = 'user'
  #     #     samAccountType    = '805306368'
  #     #   })
  #     # }
  #     # $Users | Where-Object -FilterScript ([Scriptblock]::Create($ConvertedFilter))
  #   }

  #   BeforeAll {
  #     Get-AgedAccounts -AccountType user -AgedAccountThreshold 10 -NewAccountThreshold 5
  #   }

  #   It "Retrieves only user accounts" {
  #     Assert-MockCalled Get-ADUser -Exactly 1
  #     Assert-MockCalled Get-ADComputer -Exactly 0
  #   }
  # }
  # Context "Retrieving Computer Accounts" {
  #   Function Get-ADUser ($Filter, $Properties, $Server) {}
  #   Mock Get-ADUser {}
  #   Function Get-ADComputer ($Filter, $Properties, $Server) {}
  #   Mock Get-ADComputer {}

  #   BeforeAll {
  #     Get-AgedAccounts -AccountType computer -AgedAccountThreshold 10 -NewAccountThreshold 5
  #   }

  #   It "Retrieves only computer accounts" {
  #     Assert-MockCalled Get-ADUser -Exactly 0
  #     Assert-MockCalled Get-ADComputer -Exactly 1
  #   }

  # }
}
