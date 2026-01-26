$thumbprint = "B7F70892FCB4AE515D43817962823A70B45501EA"

$cert = Get-Item "Cert:\CurrentUser\My\$thumbprint"

if (-not $cert) {
    throw "Signing certificate not found"
}

$files = Get-ChildItem docs/audit/history/*.json |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 2

if ($files.Count -lt 2) {
    Write-Host "Not enough snapshots to sign"
    exit 0
}

foreach ($file in $files) {
    Set-AuthenticodeSignature `
        -FilePath $file.FullName `
        -Certificate $cert `
        -TimestampServer "http://timestamp.digicert.com" `
        | Out-Null
}

Write-Host "✔ Latest audit snapshots signed"
