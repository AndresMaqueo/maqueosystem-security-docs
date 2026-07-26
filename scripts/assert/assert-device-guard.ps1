Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$deviceGuard = Get-CimInstance -Namespace 'root\Microsoft\Windows\DeviceGuard' -ClassName 'Win32_DeviceGuard'

[pscustomobject][ordered]@{
    ControlId = 'DG-001'
    Actual    = [int]$deviceGuard.VirtualizationBasedSecurityStatus
    Pass      = ([int]$deviceGuard.VirtualizationBasedSecurityStatus -eq 2)
    Message   = "VirtualizationBasedSecurityStatus is '$($deviceGuard.VirtualizationBasedSecurityStatus)'."
}

[pscustomobject][ordered]@{
    ControlId = 'CI-001'
    Actual    = [int]$deviceGuard.CodeIntegrityPolicyEnforcementStatus
    Pass      = ([int]$deviceGuard.CodeIntegrityPolicyEnforcementStatus -eq 2)
    Message   = "CodeIntegrityPolicyEnforcementStatus is '$($deviceGuard.CodeIntegrityPolicyEnforcementStatus)'."
}
