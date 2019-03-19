$AccountsToDelete    = Get-DisabledAccounts @ComputersToDeleteQueryParameters
If ($DeleteUsers) {
  $AccountsToDelete += Get-DisabledAccounts @UsersToDeleteQueryParameters
}
