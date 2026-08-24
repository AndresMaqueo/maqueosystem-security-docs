Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function New-SecurityScoreSummary {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [object[]]$Results,

        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [object[]]$BaselineControls,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$BaselineVersion,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Scope,

        [Parameter(Mandatory)]
        [ValidateSet('local', 'ci')]
        [string]$ExecutionMode,

        [string]$TimestampUtc = [DateTimeOffset]::UtcNow.ToString('o')
    )

    $totalWeight = [double](($BaselineControls | Measure-Object weight -Sum).Sum)
    $passedWeight = [double](($Results | Where-Object Pass | Measure-Object Weight -Sum).Sum)
    $score = if ($totalWeight -gt 0) {
        [math]::Round(($passedWeight / $totalWeight) * 100, 2)
    }
    else {
        0
    }

    [pscustomobject][ordered]@{
        SchemaVersion   = '1.0'
        BaselineVersion = $BaselineVersion
        Scope           = $Scope
        ExecutionMode   = $ExecutionMode
        Score           = $score
        PassedWeight    = $passedWeight
        TotalWeight     = $totalWeight
        ControlCount    = $BaselineControls.Count
        PassedCount     = @($Results | Where-Object Pass).Count
        FailedCount     = @($Results | Where-Object { $_.Status -eq 'Fail' }).Count
        ErrorCount      = @($Results | Where-Object { $_.Status -eq 'Error' }).Count
        TimestampUtc    = $TimestampUtc
    }
}

Export-ModuleMember -Function New-SecurityScoreSummary
