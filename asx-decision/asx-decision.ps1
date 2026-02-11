param(
  [Parameter(Mandatory, Position = 0)]
  [ValidateSet("encode", "decide", "verify", "badge", "trace", "simd", "quorum", "compress-trace")]
  [string]$Command,

  [Parameter(Position = 1)]
  [string]$Input,

  [Parameter(Position = 2)]
  [string]$Out = "out.json",

  [Parameter(Position = 3)]
  [string]$Mode = "STRICT_ALL"
)

$ScriptDir = Split-Path -Parent $PSCommandPath

switch ($Command) {
  "encode" {
    if (-not $Input) { throw "ILLEGAL: missing input path for encode" }
    & (Join-Path $ScriptDir "lib/encode-scxq4.ps1") -Input $Input -Out $Out
  }
  "decide" {
    if (-not $Input) { throw "ILLEGAL: missing input path for decide" }
    & (Join-Path $ScriptDir "lib/decide.ps1") -Input $Input -Out $Out | Out-Null
  }
  "verify" {
    & (Join-Path $ScriptDir "lib/verify.ps1")
  }
  "trace" {
    if (-not $Input) { throw "ILLEGAL: missing input path for trace" }
    & (Join-Path $ScriptDir "lib/trace.ps1") -Input $Input -Out $Out
  }
  "badge" {
    & (Join-Path $ScriptDir "lib/badge.ps1")
  }
  "simd" {
    & (Join-Path $ScriptDir "lib/simd-codegen.ps1") -Out $Out
  }
  "quorum" {
    if (-not $Input) { throw "ILLEGAL: missing verdict bundle path for quorum" }
    & (Join-Path $ScriptDir "lib/quorum.ps1") -Input $Input -Out $Out -Mode $Mode
  }
  "compress-trace" {
    if (-not $Input) { throw "ILLEGAL: missing trace path for compress-trace" }
    & (Join-Path $ScriptDir "lib/compress-trace.ps1") -Input $Input -Out $Out
  }
}
