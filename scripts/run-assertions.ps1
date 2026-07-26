[CmdletBinding()]
param(
    [switch]$CiMode,

    [ValidateNotNullOrEmpty()]
    [string]$BaselinePath = "baseline/v2026.01.json"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$resolvedBaselinePath = Join-Path $repositoryRoot $BaselinePath
$assertionDirectory = Join-Path $PSScriptRoot 'assert'

if (-not (Test-Path -LiteralPath $resolvedBaselinePath -PathType Leaf)) {
    throw "Baseline file not found: $resolvedBaselinePath"
}

if (-not (Test-Path -LiteralPath $assertionDirectory -PathType Container)) {
    throw "Assertion directory not found: $assertionDirectory"
}

$baseline = Get-Content -LiteralPath $resolvedBaselinePath -Raw | ConvertFrom-Json

if ([string]::IsNullOrWhiteSpace([string]$baseline.baselineVersion)) {
    throw 'The baseline must define baselineVersion.'
}

$baselineControls = @($baseline.controls)
if ($baselineControls.Count -eq 0) {
    throw 'The baseline must define at least one control.'
}

$duplicateBaselineIds = @(
    $baselineControls |
        Group-Object id |
        Where-Object Count -gt 1 |
        ForEach-Object Name
)

if ($duplicateBaselineIds.Count -gt 0) {
    throw "Duplicate control IDs in baseline: $($duplicateBaselineIds -join ', ')"
}

foreach ($control in $baselineControls) {
    if ([string]::IsNullOrWhiteSpace([string]$control.id)) {
        throw 'Every baseline control must define an id.'
    }

    if ([string]::IsNullOrWhiteSpace([string]$control.name)) {
        throw "Baseline control '$($control.id)' must define a name."
    }

    if ([double]$control.weight -le 0) {
        throw "Baseline control '$($control.id)' must have a positive weight."
    }
}

$baselineById = @{}
foreach ($control in $baselineControls) {
    $baselineById[[string]$control.id] = $control
}

$rawResults = [System.Collections.Generic.List[object]]::new()
$executionErrors = [System.Collections.Generic.List[string]]::new()

$assertionScripts = @(Get-ChildItem -LiteralPath $assertionDirectory -Filter '*.ps1' -File | Sort-Object Name)
if ($assertionScripts.Count -eq 0) {
    throw 'No assertion scripts were found.'
}

foreach ($script in $assertionScripts) {
    try {
        $scriptResults = @(& $script.FullName)
        foreach ($result in $scriptResults) {
            if ($null -ne $result) {
                $rawResults.Add($result)
            }
        }
    }
    catch {
        $executionErrors.Add("$($script.Name): $($_.Exception.Message)")
    }
}

$duplicateResultIds = @(
    $rawResults |
        Where-Object { $_.PSObject.Properties.Name -contains 'ControlId' } |
        Group-Object ControlId |
        Where-Object Count -gt 1 |
        ForEach-Object Name
)

if ($duplicateResultIds.Count -gt 0) {
    $executionErrors.Add("Duplicate assertion results: $($duplicateResultIds -join ', ')")
}

$normalizedResults = [System.Collections.Generic.List[object]]::new()
$observedIds = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

foreach ($result in $rawResults) {
    $properties = @($result.PSObject.Properties.Name)
    foreach ($requiredProperty in @('ControlId', 'Actual', 'Pass')) {
        if ($properties -notcontains $requiredProperty) {
            $executionErrors.Add("An assertion result is missing required property '$requiredProperty'.")
            continue
        }
    }

    $controlId = [string]$result.ControlId
    if ([string]::IsNullOrWhiteSpace($controlId)) {
        $executionErrors.Add('An assertion returned an empty ControlId.')
        continue
    }

    if (-not $baselineById.ContainsKey($controlId)) {
        $executionErrors.Add("Assertion returned unknown control ID '$controlId'.")
        continue
    }

    if (-not $observedIds.Add($controlId)) {
        continue
    }

    $definition = $baselineById[$controlId]
    $normalizedResults.Add([pscustomobject][ordered]@{
        ControlId = $controlId
        Name      = [string]$definition.name
        Expected  = [string]$definition.assertion
        Actual    = $result.Actual
        Weight    = [double]$definition.weight
        Required  = [bool]$definition.required
        Status    = if ([bool]$result.Pass) { 'Pass' } else { 'Fail' }
        Pass      = [bool]$result.Pass
        Message   = if ($properties -contains 'Message') { [string]$result.Message } else { $null }
    })
}

foreach ($definition in $baselineControls) {
    $controlId = [string]$definition.id
    if ([bool]$definition.required -and -not $observedIds.Contains($controlId)) {
        $normalizedResults.Add([pscustomobject][ordered]@{
            ControlId = $controlId
            Name      = [string]$definition.name
            Expected  = [string]$definition.assertion
            Actual    = $null
            Weight    = [double]$definition.weight
            Required  = $true
            Status    = 'Error'
            Pass      = $false
            Message   = 'Required control did not produce an assertion result.'
        })
        $executionErrors.Add("Required control '$controlId' did not produce a result.")
    }
}

$orderedResults = @($normalizedResults | Sort-Object ControlId)
$totalWeight = [double](($baselineControls | Measure-Object weight -Sum).Sum)
$passedWeight = [double](($orderedResults | Where-Object Pass | Measure-Object Weight -Sum).Sum)
$score = if ($totalWeight -gt 0) { [math]::Round(($passedWeight / $totalWeight) * 100, 2) } else { 0 }
$timestampUtc = [DateTimeOffset]::UtcNow.ToString('o')
$executionMode = if ($CiMode) { 'ci' } else { 'local' }

$auditDirectory = Join-Path $repositoryRoot 'docs/audit/2026-01'
$historyDirectory = Join-Path $repositoryRoot 'docs/audit/history'
New-Item -ItemType Directory -Path $auditDirectory -Force | Out-Null

$assertionsPath = Join-Path $auditDirectory 'assertions.json'
$scorePath = Join-Path $auditDirectory 'score.json'

ConvertTo-Json -InputObject $orderedResults -Depth 8 | Set-Content -LiteralPath $assertionsPath -Encoding utf8

$scoreObject = [pscustomobject][ordered]@{
    SchemaVersion   = '1.0'
    BaselineVersion = [string]$baseline.baselineVersion
    Scope           = [string]$baseline.scope
    ExecutionMode   = $executionMode
    Score           = $score
    PassedWeight    = $passedWeight
    TotalWeight     = $totalWeight
    ControlCount    = $baselineControls.Count
    PassedCount     = @($orderedResults | Where-Object Pass).Count
    FailedCount     = @($orderedResults | Where-Object { $_.Status -eq 'Fail' }).Count
    ErrorCount      = @($orderedResults | Where-Object { $_.Status -eq 'Error' }).Count
    TimestampUtc    = $timestampUtc
}

$scoreObject | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $scorePath -Encoding utf8

if (-not $CiMode) {
    New-Item -ItemType Directory -Path $historyDirectory -Force | Out-Null
    $historyTimestamp = [DateTimeOffset]::UtcNow.ToString('yyyyMMdd-HHmmssZ')
    Copy-Item -LiteralPath $assertionsPath -Destination (Join-Path $historyDirectory "assertions-$historyTimestamp.json")
    Copy-Item -LiteralPath $scorePath -Destination (Join-Path $historyDirectory "score-$historyTimestamp.json")
}

if ($executionErrors.Count -gt 0) {
    throw "Security baseline execution ERROR: $($executionErrors -join ' | ')"
}

if ($orderedResults.Pass -contains $false) {
    throw "Security baseline FAILED with score $score%."
}

Write-Host "Security baseline PASSED with score $score% ($executionMode mode)."
