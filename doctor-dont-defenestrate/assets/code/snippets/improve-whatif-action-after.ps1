If ($AccountsToDisable -contains $Account) {
  $AddMemberParameters.Name = 'ScriptDisabled'
  Disable-ADAccount $Account.DistinguishedName -Server $Server
  # Note that this stores the result as whether the command ran
  # without error. It does NOT ensure the account was disabled!
  # This should be addressed in a future commit.
  $AddMemberParameters.Value = $?
} ElseIf ($AccountsToDelete -contains $Account) {
