param(
  [Parameter(Mandatory)]
  [string]$Input,

  [Parameter(Mandatory)]
  [string]$Out
)

$decision = Get-Content -Raw $Input | ConvertFrom-Json -AsHashtable

$record = @{
  CTRL = "DECIDE"
  SEL  = $decision.select
  PI   = $decision.pi
  ENT  = $decision.entropy_gate
  POL  = $decision.policy
  BAN  = 0
}

$record | ConvertTo-Json -Depth 6 | Set-Content $Out
