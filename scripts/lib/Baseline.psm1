Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Import-SecurityBaseline {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Baseline file not found: $Path"
    }

    try {
        $baseline = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
    }
    catch {
        throw "Baseline file is not valid JSON: $($_.Exception.Message)"
    }

    Test-SecurityBaseline -Baseline $baseline
    return $baseline
}

function Test-SecurityBaseline {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$Baseline
    )

    if ([string]::IsNullOrWhiteSpace([string]$Baseline.baselineVersion)) {
        throw 'The baseline must define baselineVersion.'
    }

    if ([string]::IsNullOrWhiteSpace([string]$Baseline.scope)) {
        throw 'The baseline must define scope.'
    }

    $controls = @($Baseline.controls)
    if ($controls.Count -eq 0) {
        throw 'The baseline must define at least one control.'
    }

    $duplicateIds = @(
        $controls |
            Group-Object id |
            Where-Object Count -gt 1 |
            ForEach-Object Name
    )

    if ($duplicateIds.Count -gt 0) {
        throw "Duplicate control IDs in baseline: $($duplicateIds -join ', ')"
    }

    foreach ($control in $controls) {
        $controlId = [string]$control.id

        if ([string]::IsNullOrWhiteSpace($controlId)) {
            throw 'Every baseline control must define an id.'
        }

        if ([string]::IsNullOrWhiteSpace([string]$control.name)) {
            throw "Baseline control '$controlId' must define a name."
        }

        if ([string]::IsNullOrWhiteSpace([string]$control.assertion)) {
            throw "Baseline control '$controlId' must define an assertion."
        }

        if ($null -eq $control.weight -or [double]$control.weight -le 0) {
            throw "Baseline control '$controlId' must have a positive weight."
        }

        if ($null -eq $control.required) {
            throw "Baseline control '$controlId' must define required."
        }
    }

    return $true
}

function New-BaselineControlIndex {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$Baseline
    )

    $index = @{}
    foreach ($control in @($Baseline.controls)) {
        $index[[string]$control.id] = $control
    }

    return $index
}

function Get-BaselineControls {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$Baseline
    )

    return @($Baseline.controls)
}

Export-ModuleMember -Function @(
    'Import-SecurityBaseline',
    'Test-SecurityBaseline',
    'New-BaselineControlIndex',
    'Get-BaselineControls'
)
