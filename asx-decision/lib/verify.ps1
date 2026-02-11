$ScriptDir = Split-Path -Parent $PSCommandPath
$RootDir = Join-Path $ScriptDir ".."
$VectorsPath = Join-Path $RootDir "vectors/decision_vectors.json"
$QuorumBundlePath = Join-Path $RootDir "vectors/quorum_bundle.json"
$DecideScript = Join-Path $ScriptDir "decide.ps1"
$QuorumScript = Join-Path $ScriptDir "quorum.ps1"

$vectors = Get-Content -Raw $VectorsPath | ConvertFrom-Json -AsHashtable
$failed = $false

foreach ($v in $vectors) {
  $tmpIn = Join-Path $env:TEMP ("asx-vector-{0}.json" -f $v.id)
  $v | ConvertTo-Json -Depth 10 | Set-Content $tmpIn

  $out = & $DecideScript -Input $tmpIn

  if ($out.opcode -ne $v.expected.opcode -or $out.result -ne $v.expected.result) {
    Write-Host "FAIL $($v.id)" -ForegroundColor Red
    $failed = $true
  } else {
    Write-Host "PASS $($v.id)" -ForegroundColor Green
  }

  Remove-Item -Force $tmpIn
}

$quorumOutPath = Join-Path $env:TEMP "asx-quorum-out.json"
$quorum = & $QuorumScript -Input $QuorumBundlePath -Out $quorumOutPath -Mode "STRICT_ALL"
if (-not $quorum.pass) {
  Write-Host "FAIL quorum STRICT_ALL" -ForegroundColor Red
  $failed = $true
} else {
  Write-Host "PASS quorum STRICT_ALL" -ForegroundColor Green
}
Remove-Item -Force $quorumOutPath

if ($failed) { exit 1 }
