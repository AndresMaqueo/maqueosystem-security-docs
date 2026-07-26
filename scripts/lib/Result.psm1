Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function New-ControlResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidatePattern('^[A-Z]{2,10}-\d{3}$')]
        [string]$ControlId,

        [Parameter(Mandatory)]
        [AllowNull()]
        [object]$Actual,

        [Parameter(Mandatory)]
        [bool]$Pass,

        [AllowNull()]
        [AllowEmptyString()]
        [string]$Message
    )

    [pscustomobject][ordered]@{
        ControlId = $ControlId
        Actual    = $Actual
        Pass      = $Pass
        Message   = if ([string]::IsNullOrWhiteSpace($Message)) { $null } else { $Message }
    }
}

Export-ModuleMember -Function 'New-ControlResult'
