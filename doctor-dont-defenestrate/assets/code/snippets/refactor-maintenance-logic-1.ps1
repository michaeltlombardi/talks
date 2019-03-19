ForEach ($Account in $AccountsToDisable) {
  $AddMemberParameters = $AddMemberPropertyBase.Clone()
  $AddMemberParameters.InputObject = $Account
  $AddMemberParameters.Name = 'ScriptDisabled'
  If ($NamedExceptions -contains $Account.DistinguishedName) {
    # Skip the disable call if the account's distinguished name is
    # in an exception list; This makes the result a string instead
    # of a boolean, complicating post-hoc queries. This may be
    # addressed in a future commit.
    $AddMemberParameters.Value = 'Match found in named exceptions file'
  } Else {
