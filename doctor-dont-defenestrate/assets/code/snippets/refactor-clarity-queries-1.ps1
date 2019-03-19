# Retrieve the user/computer accounts to be disabled.
# These queries are hardcoded per our organizational standard.
$AgedAccounts  = $null
$AgedAccounts  = Get-AgedAccounts User 60 21
$AgedAccounts += Get-AgedAccounts Computer 45 14
# This line displays the number of accounts to be disabled and can
# probably be removed in a future commit.
$AgedAccounts.Count
