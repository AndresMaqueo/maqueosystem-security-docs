Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$resultModulePath = Join-Path (Split-Path -Parent $PSScriptRoot) 'lib/Result.psm1'
Import-Module -Name $resultModulePath -Force -ErrorAction Stop

$secureBootEnabled = [bool](Confirm-SecureBootUEFI)

New-ControlResult `
    -ControlId 'SB-001' `
    -Actual $secureBootEnabled `
    -Pass $secureBootEnabled `
    -Message "Secure Boot enabled state is '$secureBootEnabled'."
