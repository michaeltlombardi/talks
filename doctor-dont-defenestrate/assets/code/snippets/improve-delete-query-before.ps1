$AccountsToDelete    = Get-DisabledAccounts @ComputersToDeleteQueryParameters
# Uncomment the following line to also delete disabled user accounts.
# WARNING: Doing so is not easy to recover from, be sure to follow SOP!
# $AccountsToDelete += Get-DisabledAccounts @UsersToDeleteQueryParameters
