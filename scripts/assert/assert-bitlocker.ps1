$bl = Get-BitLockerVolume -MountPoint "C:"

[pscustomobject]@{
  ControlId = "BL-001"
  Name      = "BitLocker Enabled"
  Expected  = "On"
  Actual    = $bl.ProtectionStatus
  Weight    = 15
  Pass      = ($bl.ProtectionStatus -eq "On")
}
