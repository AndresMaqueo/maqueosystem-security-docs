Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$bitLockerVolume = Get-BitLockerVolume -MountPoint 'C:'
$protectionStatus = $bitLockerVolume.ProtectionStatus

[pscustomobject][ordered]@{
    ControlId = 'BL-001'
    Actual    = [string]$protectionStatus
    Pass      = ($protectionStatus -eq [Microsoft.BitLocker.Structures.BitLockerVolumeProtectionStatus]::On)
    Message   = "BitLocker protection status for C: is '$protectionStatus'."
}
