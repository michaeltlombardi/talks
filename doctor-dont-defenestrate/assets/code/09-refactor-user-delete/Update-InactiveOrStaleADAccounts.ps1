<#
  .SYNOPSIS
    Disables inactive accounts and deletes stale ones.
  .DESCRIPTION
    This Active directory cleanup script disables inactive user and
    computer accounts as defined by our organizational requirements.
    It also deletes stale computer accounts and can be modified to
    delete stale user accounts, both as defined by our organizational
    requirements. It writes the results of all actions into date-
    stamped CSV files on the machine it is run from.

    Note that you can modify the script to show you what it _would_
    do if run, but you will need to remove the commented `-WhatIf`
    parameters from Disable-ADAccount and Remove-ADObject both.
  .PARAMETER ScriptPath
    The path to the folder where the named exception list is kept and
    where the output should be logged. Must be the full path. It is
    strongly recommend you do _not_ override this without good reason.
    Make sure to include a trailing `\` - failure to do so will cause
    strings to build incorrectly.
  .PARAMETER LogDirectory
    The folder beneath the ScriptPath in which the log output is
    written; make sure to include a trailing `\` - failure to do so
    will cause strings to build incorrectly.
  .PARAMETER Date
    The date the script is run on, defaults to the current date as a
    date string; if run on February 1, 2018 it would default to
    `01-02-2018`. This is functionally a constant.
  .PARAMETER NamedExceptions
    The list of computer and user accounts which are excepted from
    the disable/delete policies, listed by distinguished name. By
    default this points to `ADNamedExceptions.txt` in the ScriptPath.
    If you DO decide to override this, be aware that any missing
    exceptions may be disabled or deleted! Also, note that you must
    provide a list of distinguished names, not the path to another
    exception file!
  .PARAMETER Server
    The Active Directory Domain Services instance to point the get,
    disable, and remove calls against. By default points to
    `DC002.domain.com`. If that DC is down you may want to point
    the script at another.
  .PARAMETER DeleteUsers
    Specify this switch to retrieve users for deletion. By default,
    this script only deletes inactive computer accounts. If this
    switch is specified and the `WhatIf` switch is not, it WILL
    delete user accounts!
  .INPUTS
    None. You cannot pipe input to this function.
  .OUTPUTS
    None.
    
    This script will return no data by default, but will log all of
    the accounts which it attempted to disable/delete and whether or
    not those actions were successful.
  .EXAMPLE
    .\Update-InactiveOrStaleADAccounts.ps1

    This executes the script using all of the default parameters.
    It will return two integers representing the number of accounts
    to be disabled/deleted.
  .EXAMPLE
    .\Update-InactiveOrStaleADAccounts.ps1 -Server DC003.other-domain.com

    This executes the script but targets a domain controller
    in another domain. It otherwises behave exactly the same.

    WARNING: If it is not run from the same domain it is targeting
    the script will fail; It doesn't include any method to authenticate
    against an alternate domain at this time.
  .EXAMPLE
    $Exceptions = 'CN=Jane Doe,OU=Sales,DC=Domain,DC=COM'
    .\Update-InactiveOrStaleADAccounts.ps1 -NamedExceptions $Exceptions

    This executes the script but passes an alternative exception list.
    In this case, *only* Jane Doe will be excepted from the attempts
    to disable inactive accounts & delete stale accounts! If you want
    to _add_ a name to the exception list you need to update the text
    file or otherwise pass the full list of folks to except as an
    array of strings to this parameter! THIS IS VERY RISKY!
  .EXAMPLE
    .\Update-InactiveOrStaleADAccounts.ps1 -DeleteUsers -WhatIf

    This executes the script in `WhatIf` mode. Note that it will
    display the `WhatIf` messages for user accounts as well as
    computer accounts that would be deleted. Drop the `WhatIf`
    switch to *actually* delete those accounts.
  .NOTES
    This script is a legacy script that has been running in prod
    (with unknown, untracked changes) since Summer 2013. The script
    is used to ensure we are meeting our organizational requirements
    for disabling inactive accounts and deleting stale ones.

    It requires some refactoring that will come in later updates.
    Namely, it needs:
    - To cleanup the parameters:
      - NamedExceptions should be handled better
      - Several parameters need to be removed or placed as constants
      - The script should take pipeline input for the exception list
      - Users should be able to pass a credential for AD commands
    - The messaging for the log output should be cleaned up
      - The logs right now may not actually verify if an account was
        acted on or not - at best they're ambiguous and optimistic

    As these problems are resolved they'll be removed from this list.
  .LINK
    https://itdocs.domain.com/ops/scripts/Update-InactiveOrStaleADAccounts
  .LINK
    https://itdocs.domain.com/security/accounts/Standards#inactive-accounts
  .LINK
    https://itdocs.domain.com/security/accounts/Standards#stale-accounts
#>
[cmdletbinding(SupportsShouldProcess=$True)]
Param (
  [string]$ScriptPath      = "C:\Automation\AD\Cleanup\",
  [string]$LogDirectory    = "logfiles\",
  [string]$Date            = (Get-Date).ToString("dd-MM-yyyy"),
  [string[]]$NamedExceptions = (Get-Content $ScriptPath`ADnamedExceptions.txt),
  [string]$Server          = "DC002.domain.com",
  [switch]$DeleteUsers
)

Begin {
  <#
    Here we dot-source two scripts which include custom functions to
    retrieve accounts from Active Directory; Get-AgedAccounts retrieves
    accounts which have been inactive for more than X days & are older
    than Y days. Get-DisabledAccounts retreives accounts which've been
    disabled for more than X days. Both functions can retrieve computer
    objects _or_ user objects. This logic is extracted away for re-use
    elsewhere.
  #>
  . $PSScriptRoot\Get-AgedAccounts.ps1
  . $PSScriptRoot\Get-DisabledAccounts.ps1

  # This hashtable is inherited in the action loops later on for detailing
  # info which will go into the CSV log files which are written at the end.
  $AddMemberPropertyBase = @{
    InputObject = $null
    MemberType  = 'NoteProperty'
    Name        = $null
    Value       = $null
  }

  # This value is reused for both log files which are written to disk.
  $LogFileBase =  $ScriptPath + $LogDirectory + $Date

  # These queries for accounts to disable or delete are hardcoded per our organizational
  # standards. See: https://itdocs.domain.com/security/accounts/Standards
  $UsersToDisableQueryParameters = @{
    AccountType          = 'User'
    AgedAccountThreshold = 60 # Retrieve accounts not logged into for >= this many days
    NewAccountThreshold  = 21 # Do not retrieve accounts younger than this many days
  }
  $ComputersToDisableQueryParameters = @{
    AccountType          = 'Computer'
    AgedAccountThreshold = 45 # Retrieve accounts not logged into for >= this many days
    NewAccountThreshold  = 14 # Do not retrieve accounts younger than this many days
  }
  $UsersToDeleteQueryParameters = @{
    AccountType           = 'User'
    LastModifiedThreshold = 183 # Retrieve accounts disabled for >= this many days
  }
  $ComputersToDeleteQueryParameters = @{
    AccountType           = 'Computer'
    LastModifiedThreshold = 183 # Retrieve accounts disabled for >= this many days
  }
}

Process {
  $AccountsToDisable  = Get-AgedAccounts @UsersToDisableQueryParameters
  $AccountsToDisable += Get-AgedAccounts @ComputersToDisableQueryParameters
  Write-Verbose "Number of accounts to be disabled: $($AccountsToDisable.Count)"

  $AccountsToDelete    = Get-DisabledAccounts @ComputersToDeleteQueryParameters
  If ($DeleteUsers) {
    $AccountsToDelete += Get-DisabledAccounts @UsersToDeleteQueryParameters
  }
  Write-Verbose "Number of accounts to be deleted: $($DisabledAccounts.Count)"


  ForEach ($Account in ($AccountsToDisable + $AccountsToDelete)) {
    $AddMemberParameters = $AddMemberPropertyBase
    $AddMemberParameters.InputObject = $Account
    If ($NamedExceptions -contains $Account.DistinguishedName) {
      # Skip the disable call if the account's distinguished name is
      # in an exception list; This makes the result a string instead
      # of a boolean, complicating post-hoc queries. This may be
      # addressed in a future commit.
      $AddMemberParameters.Value = 'Match found in named exceptions file'
    } Else {
      If ($AccountsToDisable -contains $Account) {
        $AddMemberParameters.Name = 'ScriptDisabled'
        Disable-ADAccount $Account.DistinguishedName -Server $Server
        # Note that this stores the result as whether the command ran
        # without error. It does NOT ensure the account was disabled!
        # This should be addressed in a future commit.
        $AddMemberParameters.Value = $?
      } ElseIf ($AccountsToDelete -contains $Account) {
        $AddMemberParameters.Name = 'ScriptDeleted'
        Remove-ADObject $Account.DistinguishedName -Server $Server -Confirm:$False -Recursive
        # Note that this stores the result as whether the command ran
        # without error. It does NOT ensure the account was disabled!
        # This should be addressed in a future commit.
        $AddMemberParameters.Value = $?
      }
    }
    Add-Member @AddMemberParameters
  }
}

End {
  # We log the results of the disable attempts for later review.
  $AccountsToDisable |
    Export-Csv -Path "${LogFileBase}disabled accounts.csv" -NoTypeInformation
  # We log the results of the removal attempts for later review.
  $AccountsToDelete |
    Export-Csv -Path "${LogFileBase}-deleted accounts.csv" -NoTypeInformation
}