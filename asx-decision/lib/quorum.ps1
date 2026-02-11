param(
  [Parameter(Mandatory)]
  [string]$Input,

  [Parameter(Mandatory)]
  [string]$Out,

  [ValidateSet("STRICT_ALL", "MAJORITY", "WEIGHTED")]
  [string]$Mode = "STRICT_ALL"
)

$bundle = Get-Content -Raw $Input | ConvertFrom-Json -AsHashtable
$verdicts = @($bundle.verdicts)

$required = @("L", "E", "R", "C")
$weights = @{ L = 3; E = 2; R = 2; C = 3 }

foreach ($v in $verdicts) {
  if ($required -notcontains $v."@shard") { throw "ILLEGAL: unknown shard" }
  if (-not $v.input_hash) { throw "ILLEGAL: missing input_hash" }
  if (-not $v.signature) { throw "ILLEGAL: missing signature" }
  if (("PASS", "FAIL") -notcontains $v.verdict) { throw "ILLEGAL: invalid verdict value" }
}

$passShards = @($verdicts | Where-Object { $_.verdict -eq "PASS" } | ForEach-Object { $_."@shard" })
$failWithProof = @($verdicts | Where-Object { $_.verdict -eq "FAIL" -and $_.proof -eq $true })

$pass = $false

switch ($Mode) {
  "STRICT_ALL" {
    $pass = ($passShards.Count -eq 4)
  }
  "MAJORITY" {
    $pass = ($passShards.Count -ge 3 -and $failWithProof.Count -eq 0)
  }
  "WEIGHTED" {
    $sum = 0
    foreach ($s in $passShards) { $sum += $weights[$s] }
    $hasL = $passShards -contains "L"
    $hasC = $passShards -contains "C"
    $pass = ($sum -ge 7 -and $hasL -and $hasC)
  }
}

$result = @{
  mode = $Mode
  pass = $pass
  status = if ($pass) { "PASS" } else { "ILLEGAL" }
  pass_shards = $passShards
}

$result | ConvertTo-Json -Depth 6 | Set-Content $Out
$result
