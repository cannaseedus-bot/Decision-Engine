param(
  [Parameter(Mandatory)]
  [string]$Input,

  [Parameter(Mandatory)]
  [string]$Out
)

$decision = Get-Content -Raw $Input | ConvertFrom-Json -AsHashtable

$frame = @{
  op      = "DECIDE"
  count   = $decision.select.Count
  ids     = $decision.select
  pi      = $decision.pi
  entropy = $decision.entropy_gate
  policy  = $decision.policy
  mask    = 0
}

$frame | ConvertTo-Json -Depth 6 | Set-Content $Out
