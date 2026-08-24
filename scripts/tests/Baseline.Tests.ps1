BeforeAll {
    $modulePath = Join-Path $PSScriptRoot '../lib/Baseline.psm1'
    Import-Module $modulePath -Force
}

Describe 'Baseline module' {
    It 'imports a valid baseline JSON document' {
        $path = Join-Path $TestDrive 'baseline.json'
        @'
{
  "baselineVersion": "2026.01",
  "scope": "workstation",
  "controls": [
    {
      "id": "SB-001",
      "name": "Secure Boot",
      "assertion": "Enabled",
      "weight": 10,
      "required": true
    }
  ]
}
'@ | Set-Content -LiteralPath $path -Encoding utf8

        $baseline = Import-SecurityBaseline -Path $path

        $baseline.baselineVersion | Should -Be '2026.01'
        @($baseline.controls).Count | Should -Be 1
    }

    It 'rejects a missing baseline file' {
        { Import-SecurityBaseline -Path (Join-Path $TestDrive 'missing.json') } |
            Should -Throw 'Baseline file not found:*'
    }

    It 'rejects duplicate control IDs' {
        $baseline = [pscustomobject]@{
            baselineVersion = '2026.01'
            scope = 'workstation'
            controls = @(
                [pscustomobject]@{ id = 'SB-001'; name = 'A'; assertion = 'Enabled'; weight = 10; required = $true },
                [pscustomobject]@{ id = 'SB-001'; name = 'B'; assertion = 'Enabled'; weight = 10; required = $true }
            )
        }

        { Test-SecurityBaseline -Baseline $baseline } |
            Should -Throw 'Duplicate control IDs in baseline:*'
    }

    It 'creates an index keyed by control ID' {
        $control = [pscustomobject]@{ id = 'BL-001'; name = 'BitLocker'; assertion = 'On'; weight = 20; required = $true }
        $baseline = [pscustomobject]@{
            baselineVersion = '2026.01'
            scope = 'workstation'
            controls = @($control)
        }

        $index = New-BaselineControlIndex -Baseline $baseline

        $index.Contains('BL-001') | Should -BeTrue
        $index['BL-001'].name | Should -Be 'BitLocker'
    }
}
