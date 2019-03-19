$AccountsToDisable  = Get-AgedAccounts @UsersToDisableQueryParameters
$AccountsToDisable += Get-AgedAccounts @ComputersToDisableQueryParameters
Write-Verbose "Number of accounts to be disabled: $($AccountsToDisable.Count)"
$AccountsToDisable.Count
