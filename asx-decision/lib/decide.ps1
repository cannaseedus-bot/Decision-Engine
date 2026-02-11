param(
  [Parameter(Mandatory)]
  [string]$Input,

  [string]$Out
)

$frame = Get-Content -Raw $Input | ConvertFrom-Json -AsHashtable

if (-not $frame.select -or $frame.select.Count -eq 0) {
  throw "ILLEGAL: empty selection set"
}

$entropyValue = [double]$frame.entropy
$entropyMax = [double]$frame.entropy_gate.max
$entropyGate = if ($entropyValue -le $entropyMax) { "PASS" } else { "BLOCK" }

if ($entropyGate -eq "BLOCK") {
  $policy = "FIRST"
  $weights = @{}
} else {
  $policy = [string]$frame.policy
  $weights = $frame.pi
}

switch ($policy) {
  "FIRST" {
    $winner = $frame.select[0]
  }
  "HIGHEST_PI" {
    $ranked = $weights.GetEnumerator() | Sort-Object Value -Descending
    if (-not $ranked -or $ranked.Count -eq 0) {
      throw "ILLEGAL: missing pi weights"
    }

    $maxPi = [double]$ranked[0].Value
    $ties = @($ranked | Where-Object { [double]$_.Value -eq $maxPi })
    if ($ties.Count -gt 1) {
      throw "ILLEGAL: tie at highest pi"
    }

    $winner = $ranked[0].Key
  }
  default {
    throw "ILLEGAL_POLICY"
  }
}

$result = @{
  opcode  = "COLLAPSE"
  result  = $winner
  policy  = $policy
  entropy = @{
    value = $entropyValue
    max   = $entropyMax
    gate  = $entropyGate
  }
  ranking = @{
    winner = $winner
    pi     = if ($weights.ContainsKey($winner)) { [double]$weights[$winner] } else { 0.0 }
  }
}

if ($Out) {
  $result | ConvertTo-Json -Depth 6 | Set-Content $Out
}

$result
