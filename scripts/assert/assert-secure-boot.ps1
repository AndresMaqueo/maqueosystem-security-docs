$sb = Confirm-SecureBootUEFI -ErrorAction SilentlyContinue

[pscustomobject]@{
  ControlId = "SB-001"
  Name      = "Secure Boot Enabled"
  Expected  = $true
  Actual    = $sb
  Weight    = 20
  Pass      = ($sb -eq $true)
}
