$thumbprint = "B7F70892FCB4AE515D43817962823A70B45501EA"
$cert = Get-Item "Cert:\CurrentUser\My\$thumbprint"

if (-not $cert) {
    throw "Signing certificate not found"
}

$files = Get-ChildItem docs/audit/history/*.json |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 2

foreach ($file in $files) {

    # Calcular hash
    $hash = Get-FileHash $file.FullName -Algorithm SHA256

    $hashPath = "docs/audit/history/crypto/$($file.Name).sha256"
    $hash.Hash | Set-Content $hashPath

    # Firmar hash
    $sigPath = "docs/audit/history/crypto/$($file.Name).sig"

    Set-AuthenticodeSignature `
        -FilePath $hashPath `
        -Certificate $cert `
        -TimestampServer "http://timestamp.digicert.com" `
        | Out-Null
}

Write-Host "✔ Hash + signature generated for latest snapshots"
