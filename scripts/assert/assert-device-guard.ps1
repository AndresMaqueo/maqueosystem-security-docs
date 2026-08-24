Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$resultModulePath = Join-Path (Split-Path -Parent $PSScriptRoot) 'lib/Result.psm1'
Import-Module -Name $resultModulePath -Force -ErrorAction Stop

$deviceGuard = Get-CimInstance -Namespace 'root\Microsoft\Windows\DeviceGuard' -ClassName 'Win32_DeviceGuard'
$vbsStatus = [int]$deviceGuard.VirtualizationBasedSecurityStatus
$codeIntegrityStatus = [int]$deviceGuard.CodeIntegrityPolicyEnforcementStatus

New-ControlResult `
    -ControlId 'DG-001' `
    -Actual $vbsStatus `
    -Pass ($vbsStatus -eq 2) `
    -Message "VirtualizationBasedSecurityStatus is '$vbsStatus'."

New-ControlResult `
    -ControlId 'CI-001' `
    -Actual $codeIntegrityStatus `
    -Pass ($codeIntegrityStatus -eq 2) `
    -Message "CodeIntegrityPolicyEnforcementStatus is '$codeIntegrityStatus'."
