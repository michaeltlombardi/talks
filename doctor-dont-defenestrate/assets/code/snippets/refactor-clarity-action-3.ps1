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
    # You must remember to uncomment the whatif param to verify which
    # accounts WILL BE DISABLED. This should be handled at a higher
    # level for the script, not here. This should be addressed in a
    # future commit.
    Disable-ADAccount $Account.DistinguishedName -Server $Server # -WhatIf
    # Note that this stores the result as whether the command ran
    # without error. It does NOT ensure the account was disabled!
    # This should be addressed in a future commit.
    $AddMemberParameters.Value = $?
  }
  Add-Member @AddMemberParameters
}
