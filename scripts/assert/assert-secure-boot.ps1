Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$secureBootEnabled = Confirm-SecureBootUEFI

[pscustomobject][ordered]@{
    ControlId = 'SB-001'
    Actual    = [bool]$secureBootEnabled
    Pass      = ([bool]$secureBootEnabled -eq $true)
    Message   = "Secure Boot enabled state is '$secureBootEnabled'."
}
