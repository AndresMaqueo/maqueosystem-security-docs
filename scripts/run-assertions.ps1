$ErrorActionPreference = 'Stop'

$results = @()

Get-ChildItem ./scripts/assert/*.ps1 | ForEach-Object {
  $results += & $_
}

# Guardar assertions actuales
$assertionsPath = "docs/audit/2026-01/assertions.json"
$results | ConvertTo-Json -Depth 5 | Set-Content $assertionsPath

# Calcular score
$total = ($results | Measure-Object Weight -Sum).Sum
$score = ($results | Where-Object Pass | Measure-Object Weight -Sum).Sum

$scoreObject = [pscustomobject]@{
  BaselineVersion = "v2026.01"
  Score           = [math]::Round(($score / $total) * 100, 2)
  Timestamp       = (Get-Date).ToString("s")
}

$scorePath = "docs/audit/2026-01/score.json"
$scoreObject | ConvertTo-Json | Set-Content $scorePath

# ===== HISTORIAL (SE EJECUTA SIEMPRE) =====
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

Copy-Item $assertionsPath "docs/audit/history/assertions-$timestamp.json"
Copy-Item $scorePath      "docs/audit/history/score-$timestamp.json"

# ===== ENFORCEMENT AL FINAL =====
if ($results.Pass -contains $false) {
  throw "❌ Security baseline FAILED"
}

Write-Host "✅ Security baseline PASSED"
