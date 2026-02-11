param(
  [Parameter(Mandatory)]
  [string]$Input,

  [Parameter(Mandatory)]
  [string]$Out
)

$trace = Get-Content -Raw $Input | ConvertFrom-Json -AsHashtable

$policyMap = @{
  "FIRST" = "⟁P1"
  "LAST" = "⟁P2"
  "HIGHEST_PI" = "⟁P3"
  "LOWEST_PI" = "⟁P4"
  "STABLE" = "⟁P5"
  "DETERMINISTIC" = "⟁P6"
}

$entropyToken = if ($trace.entropy.gate -eq "PASS") { "⟁E+" } else { "⟁E−" }
$policyToken = if ($policyMap.ContainsKey([string]$trace.policy)) { $policyMap[[string]$trace.policy] } else { "⟁P0" }
$winnerToken = "⟁W[$($trace.result)]"
$opcodeToken = if ($trace.opcode -eq "COLLAPSE") { "⟁C1" } else { "⟁FF" }

$tokens = @("⟁TRC", $entropyToken, $policyToken, $winnerToken, $opcodeToken)

$compressed = @{
  trace = [string]::Join(" ", $tokens)
  chain = @{
    prev_hash = if ($trace.prev_hash) { $trace.prev_hash } else { $null }
    curr_hash = $trace.frame_hash
  }
}

$compressed | ConvertTo-Json -Depth 6 | Set-Content $Out
$compressed
