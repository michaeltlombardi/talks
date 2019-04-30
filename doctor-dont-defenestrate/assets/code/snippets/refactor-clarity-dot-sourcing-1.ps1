<#
  Here we dot-source two scripts which include custom functions to
  retrieve accounts from Active Directory; Get-AgedAccounts retrieves
  accounts which have been inactive for more than X days & are older
  than Y days. Get-DisabledAccounts retreives accounts which've been
  disabled for more than X days. Both functions can retrieve computer
  objects _or_ user objects. This logic is extracted away for re-use
  elsewhere.
#>
. .\Get-AgedAccounts.ps1
. .\Get-DisabledAccounts.ps1
