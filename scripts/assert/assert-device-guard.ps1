$dg = Get-CimInstance -Namespace root\Microsoft\Windows\DeviceGuard `
  -ClassName Win32_DeviceGuard

[pscustomobject]@{
  ControlId = "DG-001"
  Name      = "Virtualization-Based Security"
  Expected  = 2
  Actual    = $dg.VirtualizationBasedSecurityStatus
  Weight    = 20
  Pass      = ($dg.VirtualizationBasedSecurityStatus -eq 2)
}

[pscustomobject]@{
  ControlId = "CI-001"
  Name      = "Hypervisor-Enforced Code Integrity"
  Expected  = 2
  Actual    = $dg.CodeIntegrityPolicyEnforcementStatus
  Weight    = 25
  Pass      = ($dg.CodeIntegrityPolicyEnforcementStatus -eq 2)
}
