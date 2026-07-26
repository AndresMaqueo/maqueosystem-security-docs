Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Resolve-AssertionResults {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [object[]]$RawResults,

        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [object[]]$BaselineControls,

        [Parameter(Mandatory)]
        [System.Collections.IDictionary]$BaselineById
    )

    $validationErrors = [System.Collections.Generic.List[string]]::new()
    $normalizedResults = [System.Collections.Generic.List[object]]::new()
    $observedIds = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

    $duplicateResultIds = @(
        $RawResults |
            Where-Object { $_.PSObject.Properties.Name -contains 'ControlId' } |
            Group-Object ControlId |
            Where-Object Count -gt 1 |
            ForEach-Object Name
    )

    if ($duplicateResultIds.Count -gt 0) {
        $validationErrors.Add("Duplicate assertion results: $($duplicateResultIds -join ', ')")
    }

    foreach ($result in $RawResults) {
        $properties = @($result.PSObject.Properties.Name)
        $isValidResult = $true

        foreach ($requiredProperty in @('ControlId', 'Actual', 'Pass')) {
            if ($properties -notcontains $requiredProperty) {
                $validationErrors.Add("An assertion result is missing required property '$requiredProperty'.")
                $isValidResult = $false
            }
        }

        if (-not $isValidResult) {
            continue
        }

        $controlId = [string]$result.ControlId
        if ([string]::IsNullOrWhiteSpace($controlId)) {
            $validationErrors.Add('An assertion returned an empty ControlId.')
            continue
        }

        if (-not $BaselineById.Contains($controlId)) {
            $validationErrors.Add("Assertion returned unknown control ID '$controlId'.")
            continue
        }

        if (-not $observedIds.Add($controlId)) {
            continue
        }

        $definition = $BaselineById[$controlId]
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

    foreach ($definition in $BaselineControls) {
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
            $validationErrors.Add("Required control '$controlId' did not produce a result.")
        }
    }

    [pscustomobject][ordered]@{
        Results = @($normalizedResults | Sort-Object ControlId)
        Errors  = @($validationErrors)
    }
}

Export-ModuleMember -Function Resolve-AssertionResults
