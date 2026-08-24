[CmdletBinding()]
param(
    [switch]$CiMode,

    [ValidateNotNullOrEmpty()]
    [string]$BaselinePath = 'baseline/v2026.01.json'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$resolvedBaselinePath = Join-Path $repositoryRoot $BaselinePath
$assertionDirectory = Join-Path $PSScriptRoot 'assert'
$baselineModulePath = Join-Path $PSScriptRoot 'lib/Baseline.psm1'
$validationModulePath = Join-Path $PSScriptRoot 'lib/Validation.psm1'
$scoreModulePath = Join-Path $PSScriptRoot 'lib/Score.psm1'

foreach ($requiredModulePath in @($baselineModulePath, $validationModulePath, $scoreModulePath)) {
    if (-not (Test-Path -LiteralPath $requiredModulePath -PathType Leaf)) {
        throw "Required module not found: $requiredModulePath"
    }
}

if (-not (Test-Path -LiteralPath $assertionDirectory -PathType Container)) {
    throw "Assertion directory not found: $assertionDirectory"
}

Import-Module -Name $baselineModulePath -Force -ErrorAction Stop
Import-Module -Name $validationModulePath -Force -ErrorAction Stop
Import-Module -Name $scoreModulePath -Force -ErrorAction Stop

$baseline = Import-SecurityBaseline -Path $resolvedBaselinePath
$baselineControls = @(Get-BaselineControls -Baseline $baseline)
$baselineById = New-BaselineControlIndex -Baseline $baseline

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

$validation = Resolve-AssertionResults `
    -RawResults @($rawResults) `
    -BaselineControls $baselineControls `
    -BaselineById $baselineById

$orderedResults = @($validation.Results)
foreach ($validationError in @($validation.Errors)) {
    $executionErrors.Add([string]$validationError)
}

$executionMode = if ($CiMode) { 'ci' } else { 'local' }
$scoreObject = New-SecurityScoreSummary `
    -Results $orderedResults `
    -BaselineControls $baselineControls `
    -BaselineVersion ([string]$baseline.baselineVersion) `
    -Scope ([string]$baseline.scope) `
    -ExecutionMode $executionMode

$auditDirectory = Join-Path $repositoryRoot 'docs/audit/2026-01'
$historyDirectory = Join-Path $repositoryRoot 'docs/audit/history'
New-Item -ItemType Directory -Path $auditDirectory -Force | Out-Null

$assertionsPath = Join-Path $auditDirectory 'assertions.json'
$scorePath = Join-Path $auditDirectory 'score.json'

ConvertTo-Json -InputObject $orderedResults -Depth 8 | Set-Content -LiteralPath $assertionsPath -Encoding utf8
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
    throw "Security baseline FAILED with score $($scoreObject.Score)%."
}

Write-Host "Security baseline PASSED with score $($scoreObject.Score)% ($executionMode mode)."
