/*
 BlueVoid.metal
 iShader

 Created by Treata Norouzi on 3/1/24.

 Based on: https://www.shadertoy.com/view/lslGWr
*/

#include <metal_stdlib>
using namespace metal;


// http://www.fractalforums.com/new-theories-and-research/very-simple-formula-for-fractal-patterns/
static half field(float3 p, float iTime) {
    // brightness flickering by changing "1.e-6"
    half strength = 7 + 0.03 * log(1.e-6 + fract(sin(iTime) * 4373.11));
    half accum = 0;
    half prev = 0;
    half tw = 0;
    for (int i = 0; i < 32; ++i) {
        float mag = dot(p, p);
        p = abs(p)/mag + float3(-0.5, -0.4, -1.5);
        half w = exp(-half(i) / 7);
        accum += w * exp(-strength * pow(abs(mag - prev), 2.3));
        tw += w;
        prev = mag;
    }
    return max(0.0, 5 * accum / tw - 0.7);
}

// MARK: - Main

[[ stitchable ]] half4 blueVoid(
    float2 position, float4 bounds,
    float iTime, float2 iMouse
) {
    half2 uv = half2( 2*position / bounds.zw - 1 );
    half2 uvs = uv * half2( bounds.zw/max(bounds.z, bounds.w) );
    uvs += half2(iMouse);
    
    float3 p = float3(float2(uvs) / 4, 0) + float3(1, -1.3, 0);
    p += float3( 0.2 * half3(sin(iTime/16), sin(iTime/12),  sin(iTime/128)) );
    float t = field(p, iTime);
    float v = (1 - exp((abs(uv.x) - 1) * 6)) * (1 - exp((abs(uv.y) - 1) * 6));
    
    half t2 = t*t;
    return half4(mix(0.4, 1, v) * half4(1.8 * t2*t, 1.4 * t2, t, 1));
}
