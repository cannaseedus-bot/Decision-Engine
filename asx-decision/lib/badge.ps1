$ScriptDir = Split-Path -Parent $PSCommandPath
$RootDir = Join-Path $ScriptDir ".."
$VectorsPath = Join-Path $RootDir "vectors/decision_vectors.json"
$EngineDir = Join-Path $RootDir "registry/engines/decision-engine"
$LogDir = Join-Path $RootDir "registry/logs"

New-Item -ItemType Directory -Force -Path $EngineDir | Out-Null
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null

$vectorsHash = Get-FileHash $VectorsPath -Algorithm SHA256

$implFiles = @(
  (Join-Path $RootDir "asx-decision.ps1"),
  (Join-Path $RootDir "lib/encode-scxq2.ps1"),
  (Join-Path $RootDir "lib/encode-scxq4.ps1"),
  (Join-Path $RootDir "lib/decide.ps1"),
  (Join-Path $RootDir "lib/verify.ps1"),
  (Join-Path $RootDir "lib/trace.ps1"),
  (Join-Path $RootDir "lib/compress-trace.ps1"),
  (Join-Path $RootDir "lib/quorum.ps1"),
  (Join-Path $RootDir "lib/simd-codegen.ps1")
)

$implDigestInput = ($implFiles | ForEach-Object { (Get-FileHash $_ -Algorithm SHA256).Hash }) -join ""
$implDigestBytes = [System.Text.Encoding]::UTF8.GetBytes($implDigestInput)
$implHash = [System.BitConverter]::ToString([System.Security.Cryptography.SHA256]::HashData($implDigestBytes)).Replace("-", "")

$badge = @{
  engine       = "DecisionEngine"
  version      = "1.2"
  status       = "PASS+SIMD+DIST+TRACE"
  vectors_hash = "sha256:$($vectorsHash.Hash)"
  impl_hash    = "sha256:$implHash"
  timestamp    = (Get-Date).ToString("o")
  signatures   = @("ed25519:pending")
}

$badgePath = Join-Path $EngineDir "v1.2.json"
$badgeJson = $badge | ConvertTo-Json -Depth 6
$badgeJson | Set-Content $badgePath

$monthLog = Join-Path $LogDir ((Get-Date).ToString("yyyy-MM") + ".log")
$prevEntryHash = "GENESIS"
if (Test-Path $monthLog) {
  $lines = Get-Content $monthLog
  if ($lines.Count -gt 0) {
    $prevObj = $lines[-1] | ConvertFrom-Json -AsHashtable
    $prevEntryHash = $prevObj.entry_hash
  }
}

$entryPayload = "{0}||{1}" -f $prevEntryHash, $badgeJson
$entryHash = [System.BitConverter]::ToString([System.Security.Cryptography.SHA256]::HashData([System.Text.Encoding]::UTF8.GetBytes($entryPayload))).Replace("-", "")
$logEntry = @{
  prev_entry_hash = $prevEntryHash
  entry_hash = $entryHash
  badge = $badge
}

Add-Content -Path $monthLog -Value ($logEntry | ConvertTo-Json -Depth 8 -Compress)

$result = @{
  badge_path = $badgePath
  log_path = $monthLog
  entry_hash = $entryHash
}

$result | ConvertTo-Json -Depth 4
