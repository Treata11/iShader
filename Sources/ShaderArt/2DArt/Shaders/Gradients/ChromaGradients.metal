/*
 ChromaGradients.metal
 iShader

 Created by Treata Norouzi on 2/18/24.

 Based on: https://www.shadertoy.com/view/mtKfDG
*/

#include <metal_stdlib>
using namespace metal;


// TODO: Optimization required.

//    Simplex 3D Noise
//    by Ian McEwan, Ashima Arts
static float4 permute(float4 x){return fmod(((x*34.0)+1.0)*x, 289.0);}
static float4 taylorInvSqrt(float4 r){return 1.79284291400159 - 0.85373472095314 * r;}

static float snoise(float3 v){
  const float2  C = float2(1.0/6.0, 1.0/3.0) ;
  const float4  D = float4(0, 0.5, 1, 2);

// First corner
  float3 i  = floor(v + dot(v, C.yyy) );
  float3 x0 =   v - i + dot(i, C.xxx) ;

// Other corners
  float3 g = step(x0.yzx, x0.xyz);
  float3 l = 1 - g;
  float3 i1 = min( g.xyz, l.zxy );
  float3 i2 = max( g.xyz, l.zxy );

  //  x0 = x0 - 0. + 0.0 * C
  float3 x1 = x0 - i1 + 1.0 * C.xxx;
  float3 x2 = x0 - i2 + 2.0 * C.xxx;
  float3 x3 = x0 - 1. + 3.0 * C.xxx;

// Permutations
  i = fmod(i, 289.0 );
  float4 p = permute( permute( permute(
             i.z + float4(0.0, i1.z, i2.z, 1.0 ))
           + i.y + float4(0.0, i1.y, i2.y, 1.0 ))
           + i.x + float4(0.0, i1.x, i2.x, 1.0 ));

// Gradients
// ( N*N points uniformly over a square, mapped onto an octahedron.)
  float n_ = 1.0/7.0; // N=7
  float3  ns = n_ * D.wyz - D.xzx;

  float4 j = p - 49.0 * floor(p * ns.z *ns.z);  //  mod(p,N*N)

  float4 x_ = floor(j * ns.z);
  float4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)

  float4 x = x_ *ns.x + ns.yyyy;
  float4 y = y_ *ns.x + ns.yyyy;
  float4 h = 1.0 - abs(x) - abs(y);

  float4 b0 = float4( x.xy, y.xy );
  float4 b1 = float4( x.zw, y.zw );

  float4 s0 = floor(b0)*2.0 + 1.0;
  float4 s1 = floor(b1)*2.0 + 1.0;
  float4 sh = -step(h, float4(0.0));

  float4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
  float4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;

  float3 p0 = float3(a0.xy,h.x);
  float3 p1 = float3(a0.zw,h.y);
  float3 p2 = float3(a1.xy,h.z);
  float3 p3 = float3(a1.zw,h.w);

//Normalise gradients
  float4 norm = taylorInvSqrt(float4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;

// Mix final noise value
  float4 m = max(0.6 - float4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
  m = m * m;
  return 42.0 * dot( m*m, float4( dot(p0,x0), dot(p1,x1),
                                dot(p2,x2), dot(p3,x3) ) );
}

#define S smoothstep

static float N(float2 u, float o, float time) {
    float t = (time + o) * .2;
    float n = snoise(float3(u.x * .9 + t, u.y * .9 - t, t));
    return snoise(float3(n * .2, n * .7, t * .1));
}

static float C(float2 u, float n, float s, float z) {
    return S(S(.1, s, length(u)), 0., length(u * float2(z * .8, z) + n * .3) - .3);
}

// MARK: - Main

[[ stitchable ]] half4 chromaGradients(float2 position, float4 bounds, float time) {
    float2 uv = (position - 0.5 * bounds.zw) / min(bounds.z, bounds.w);
    float c1 = C(uv, N(uv * 0.6, 1, time), 1.2, 1.1);
    float c2 = C(uv, N(uv * 0.5, 3, time), 1.5, 1.4);
    float n = 0.08 * snoise(float3(uv * 300, time * 0.2));
    
    half3 C = mix(
            half3(n * 0.1 + 0.9),
            n + mix(
                half3(1, 0.5 - uv.y * 0.4, 0) * 1.3,
                half3(uv.x + 0.75, 0.3, 1) * 0.9,
                clamp(-.14, .9, c1 - c2)
            ),
            clamp(0.0, 1.0, c1 + c2)
        );
    
    return half4(C, 1);
}
