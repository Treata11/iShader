/*
 StarField.metal
 iShader

 Created by Treata Norouzi on 3/14/24.

 Based on: https://www.shadertoy.com/view/DsBfzm
*/

#include <metal_stdlib>
using namespace metal;

// TODO: Implement the sound too.

static float rand2(float2 co) { 
    return fract(sin(dot(co, float2(12.9898, 70.233))) * 43758.5453);
}

static float2 Rot(float2 p, float th) {
    half cth = cos(th), sth = sin(th);
    return float2(p.x*cth - p.y*sth, p.x*sth + p.y*cth);
}

// MARK: - Main

[[ stitchable ]] half4 starField(
   float2 position, half4 color, float4 bounds, float iTime
) {
    float2 uv = position/bounds.zw;
    float3 r = normalize(float3(Rot(uv - float2(0.5, 0.5 + 0.35*sin(0.157 * iTime)), 0.4 * sin(0.3 * iTime)), 1));
    color = half4(0, 0, 0, 1);
    
    for (float a = 0.015; a < 0.3; a += 0.012) {
        float k = -a / r.y;
        float2 m = (k * r.xz * float2(10, 20.3 * a)) - float2(23 * rand2(float2(a)), sign(r.y) * 0.15 * iTime);
        float3 col2 = float3(rand2(floor(m * 60)) < 0.97);
        float p = smoothstep(0.8, 0.9, (1 - 2*length(fract(m * 60) - float2(0.5))));
        col2 = p * smoothstep(0.5, 0.3, col2) / pow(abs(k), 0.9);
        float p2 = 1 - 2*length(fract(m * 3) - float2(0.5));
        col2 += pow(p2, 2) * float3(0.3, 0, 0.3) * rand2(floor(m * 3));
        color.xyz = half3( max(float3(color.xyz), pow(abs(r.y), 0.4) * col2 / (20 * a + 1)) );
    }
    
    color.xyz += 1.3 * (1 - 1.4 * abs(r.x)) * (pow(1 - abs(r.y), 2) * half3(0.0, 0.2, 0.8) + pow(1 - abs(r.y), 40.4) * half3(0.1, 0.7, 0.95));
    color.xyz += 0.9 * pow(1 - 2*length(r.xy), 6);
    
    return color;
}
