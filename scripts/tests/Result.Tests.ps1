BeforeAll {
    $modulePath = Join-Path $PSScriptRoot '../lib/Result.psm1'
    Import-Module $modulePath -Force
}

Describe 'Result module' {
    It 'creates a standardized passing result' {
        $result = New-ControlResult -ControlId 'SB-001' -Actual $true -Pass $true -Message 'Enabled'

        $result.ControlId | Should -Be 'SB-001'
        $result.Actual | Should -BeTrue
        $result.Pass | Should -BeTrue
        $result.Message | Should -Be 'Enabled'
    }

    It 'normalizes an empty message to null' {
        $result = New-ControlResult -ControlId 'BL-001' -Actual 'On' -Pass $true -Message ''

        $result.Message | Should -BeNullOrEmpty
    }

    It 'accepts a null Actual value' {
        $result = New-ControlResult -ControlId 'DG-001' -Actual $null -Pass $false

        $result.Actual | Should -BeNullOrEmpty
        $result.Pass | Should -BeFalse
    }

    It 'rejects an invalid control ID format' {
        { New-ControlResult -ControlId 'invalid' -Actual $true -Pass $true } |
            Should -Throw
    }

    It 'requires the Pass parameter' {
        { New-ControlResult -ControlId 'SB-001' -Actual $true } |
            Should -Throw
    }
}
