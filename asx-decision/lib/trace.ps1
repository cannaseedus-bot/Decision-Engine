param(
  [Parameter(Mandatory)]
  [string]$Input,

  [Parameter(Mandatory)]
  [string]$Out,

  [string]$PrevTrace
)

$collapse = Get-Content -Raw $Input | ConvertFrom-Json -AsHashtable
$inputBytes = [System.Text.Encoding]::UTF8.GetBytes((Get-Content -Raw $Input))
$hashBytes = [System.Security.Cryptography.SHA256]::HashData($inputBytes)
$hash = [System.BitConverter]::ToString($hashBytes).Replace("-", "")

$prevHash = $null
if ($PrevTrace) {
  $prev = Get-Content -Raw $PrevTrace | ConvertFrom-Json -AsHashtable
  $prevHash = $prev.frame_hash
}

$trace = @{
  "@trace"    = "decision"
  frame_hash  = $hash
  prev_hash   = $prevHash
  entropy     = $collapse.entropy
  policy      = $collapse.policy
  ranking     = $collapse.ranking
  opcode      = $collapse.opcode
  result      = $collapse.result
}

$trace | ConvertTo-Json -Depth 8 | Set-Content $Out
$trace
