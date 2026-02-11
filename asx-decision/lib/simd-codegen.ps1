param(
  [string]$Out = "simd-spec.json"
)

$spec = @{
  profile = "SCXQ4-SIMD"
  canonical_vector_shape = @{
    lanes = 8
    id_type = "i32"
    mask_type = "i32"
    pi_type = "f32"
    padding = @{
      mask = -1
      pi = 0.0
    }
  }
  targets = @{
    x86_sse = @{
      width_bits = 128
      fallback = "scalar"
      snippet = @'
__m128 pi0 = _mm_loadu_ps(&pi[0]);
__m128 pi1 = _mm_loadu_ps(&pi[4]);
__m128 m0  = _mm_castsi128_ps(_mm_loadu_si128((__m128i*)&mask[0]));
__m128 m1  = _mm_castsi128_ps(_mm_loadu_si128((__m128i*)&mask[4]));
pi0 = _mm_andnot_ps(m0, pi0);
pi1 = _mm_andnot_ps(m1, pi1);
__m128 maxv = _mm_max_ps(pi0, pi1);
maxv = _mm_max_ps(maxv, _mm_shuffle_ps(maxv, maxv, 0b01001110));
maxv = _mm_max_ps(maxv, _mm_shuffle_ps(maxv, maxv, 0b10110001));
'@
    }
    x86_avx = @{
      width_bits = 256
      fallback = "x86_sse"
      snippet = @'
__m256 pv = _mm256_loadu_ps(&pi[0]);
__m256 mv = _mm256_castsi256_ps(_mm256_loadu_si256((__m256i*)&mask[0]));
pv = _mm256_andnot_ps(mv, pv);
// Reduce max then perform tie detection against reduced scalar max.
'@
    }
    arm_neon = @{
      width_bits = 128
      fallback = "scalar"
      snippet = @'
float32x4_t pi0 = vld1q_f32(&pi[0]);
float32x4_t pi1 = vld1q_f32(&pi[4]);
uint32x4_t m0 = vld1q_u32((uint32_t*)&mask[0]);
uint32x4_t m1 = vld1q_u32((uint32_t*)&mask[4]);
pi0 = vbslq_f32(vmvnq_u32(m0), pi0, vdupq_n_f32(0.0f));
pi1 = vbslq_f32(vmvnq_u32(m1), pi1, vdupq_n_f32(0.0f));
float32x4_t maxv = vmaxq_f32(pi0, pi1);
maxv = vmaxq_f32(maxv, vextq_f32(maxv, maxv, 2));
maxv = vmaxq_f32(maxv, vextq_f32(maxv, maxv, 1));
'@
    }
  }
  invariants = @(
    "Tie detection is mandatory; ties at max pi are ILLEGAL",
    "Result index must match scalar SCXQ4 exactly"
  )
}

$spec | ConvertTo-Json -Depth 8 | Set-Content $Out
$spec
