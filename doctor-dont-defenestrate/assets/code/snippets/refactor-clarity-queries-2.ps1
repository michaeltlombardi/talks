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
