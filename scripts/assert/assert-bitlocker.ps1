Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$resultModulePath = Join-Path (Split-Path -Parent $PSScriptRoot) 'lib/Result.psm1'
Import-Module -Name $resultModulePath -Force -ErrorAction Stop

$bitLockerVolume = Get-BitLockerVolume -MountPoint 'C:'
$protectionStatus = $bitLockerVolume.ProtectionStatus

New-ControlResult `
    -ControlId 'BL-001' `
    -Actual ([string]$protectionStatus) `
    -Pass ($protectionStatus -eq [Microsoft.BitLocker.Structures.BitLockerVolumeProtectionStatus]::On) `
    -Message "BitLocker protection status for C: is '$protectionStatus'."
