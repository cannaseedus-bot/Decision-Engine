# ASX Decision Engine CLI (PowerShell)

Package name: `asx-decision`  
Host: **PowerShell 7+**  
Authority: **none** (projection + verification only)

## Canonical layout

```text
asx-decision/
├─ asx-decision.ps1
├─ lib/
│  ├─ encode-scxq2.ps1
│  ├─ encode-scxq4.ps1
│  ├─ decide.ps1
│  ├─ verify.ps1
│  ├─ trace.ps1
│  ├─ compress-trace.ps1
│  ├─ quorum.ps1
│  ├─ simd-codegen.ps1
│  ├─ badge.ps1
│  └─ wasm.ps1
├─ vectors/
│  ├─ decision_vectors.json
│  └─ quorum_bundle.json
└─ registry/
   ├─ engines/decision-engine/
   ├─ logs/
   └─ badges/
```

## Commands

```powershell
# encode decision to SCXQ4 JSON frame
.\asx-decision.ps1 encode decision.json frame.json

# collapse with entropy gate + policy
.\asx-decision.ps1 decide frame.json result.json

# run conformance vectors + strict quorum check
.\asx-decision.ps1 verify

# emit trace attestation
.\asx-decision.ps1 trace result.json trace.json

# compress trace to SCXQ2-like symbolic tokens
.\asx-decision.ps1 compress-trace trace.json trace.scxq2.json

# evaluate shard verdict bundle
.\asx-decision.ps1 quorum vectors\quorum_bundle.json quorum.out.json WEIGHTED

# emit SIMD codegen spec for x86/ARM parity
.\asx-decision.ps1 simd simd-spec.json

# publish badge + append transparency log entry
.\asx-decision.ps1 badge
```

## Canonical extensions implemented

- **SCXQ4-SIMD spec**: fixed 8-lane shape, padding, x86 SSE/AVX and ARM NEON snippets, parity invariants.
- **Shard quorum**: `STRICT_ALL`, `MAJORITY`, and `WEIGHTED` modes with required shard rules.
- **Trace compression**: deterministic symbolic tokens (`⟁TRC`, `⟁E±`, `⟁P#`, `⟁W[id]`, `⟁C1/⟁FF`) plus chain links.
- **Badge transparency**: versioned engine registry record + append-only month log with chained hashes.

## Execution law

- verification failures are hard stops (`ILLEGAL`)
- deterministic collapse via policy + π + entropy gate
- trace, quorum, and badge layers verify legality; they never change outcomes
