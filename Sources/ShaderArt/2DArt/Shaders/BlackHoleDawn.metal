/*
 BlackHoleDawn.metal
 iShader

 Created by Treata Norouzi on 3/1/24.

 Based on: https://www.shadertoy.com/view/lXsSRN
*/

#include <metal_stdlib>
using namespace metal;


// MARK: - Common

// https://www.shadertoy.com/view/4sfGzS
/// this hash is not production ready, please replace this by something better
static float hash(int3 p) {
    // 3D -> 1D
    int n = p.x * 3 + p.y * 113 + p.z * 311;

    // 1D hash by Hugo Elias
    n = (n << 13) ^ n;
    n = n * (n * n * 15731 + 789221) + 1376312589;

    // Bitwise AND operation and normalization in Metal
    int mask = 0x0fffffff;
    return float(n & mask) / float(mask);
}

static float noise(float3 x) {
    int3 i = int3(floor(x));
    float3 f = fract(x);
    f = f*f*(3 - 2*f);
    
    return mix(mix(mix( hash(i + int3(0)),
                        hash(i + int3(1, 0, 0)), f.x),
                   mix( hash(i + int3(0, 1, 0)),
                        hash(i + int3(1, 1, 0)), f.x), f.y),
               mix(mix( hash(i + int3(0, 0, 1)),
                        hash(i + int3(1, 0, 1)), f.x),
                   mix( hash(i + int3(0, 1, 1)),
                        hash(i + int3(1)), f.x), f.y), f.z);
}

// https://www.shadertoy.com/view/XsGfWV
static half3 aces_tonemap(float3 color){
    float3x3 m1 = float3x3(
        0.59719, 0.07600, 0.02840,
        0.35458, 0.90834, 0.13383,
        0.04823, 0.01566, 0.83777
    );
    float3x3 m2 = float3x3(
        1.60475, -0.10208, -0.00327,
        -0.53108,  1.10813, -0.07276,
        -0.07367, -0.00605,  1.07602
    );
    float3 v = m1 * color;
    float3 a = v * (v + 0.0245786) - 0.000090537;
    float3 b = v * (0.983729 * v + 0.4329510) + 0.238081;
    
    return pow( half3( clamp(m2 * (a / b), 0.0, 1.0) ), half3(1 / 2.2));
}

static float2 r(float2 p, float a) {
    half c = cos(a), s = sin(a);
    return p*float2x2(c, s, -s, c); // Transposed matrix
}

// MARK: - Main

[[ stitchable ]] half4 blackHoleDawn(float2 position, float4 bounds, half4 color, float iTime) {
    float2 uv = position/bounds.zw;
    float2 p = (2*position - bounds.zw) / min(bounds.z, bounds.w);
    
    float fp = pow(0.5/length(pow(abs(r(p, 0.43)) * float2(2, 1), 0.5)), 4.5);
       
    p *= float2x2(0.7, -0.5, -0.4, 1.2);
    float3 pos = normalize(float3(r(p, -0.4/length(p)), 0.25));
    pos.z -= iTime*2;
    
    float3 q = 6*pos;
    float f  = 0.5000*noise(q); q *= 2;
          f += 0.2500*noise(q); q *= 2;
          f += 0.1250*noise(q); q *= 2;
          f += 0.0625*noise(q); q *= 2;
    
    float2 n = uv*(1 - uv)*3;
    float v = pow(n.x * n.y, 0.8);
    
    float fr = 0.6/length(p);
    f = smoothstep(-0.4, 2, f*f) * fr*fr + fp;
    
    return half4(aces_tonemap(
        pow(f*f * float3(color.xyz * 2)*v, float3(0.45)) * 3.5), 1);
}
