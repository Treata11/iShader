/*
 FBMLightning.metal
 iShader

 Created by Treata Norouzi on 2/25/24.

 Based on: https://www.shadertoy.com/view/dsXfDn
*/

#include <metal_stdlib>
using namespace metal;


static float hash11(float p) {
    p = fract(p * 0.1031);
    p *= p + 33.33;
    p *= p + p;
    
    return fract(p);
}

static float hash12(float2 p) {
    float3 p3 = fract(float3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    
    return fract((p3.x + p3.y) * p3.z);
}

static float2x2 rotate2d(float theta) {
    half c = cos(theta), s = sin(theta);
    return float2x2(c, -s, s, c);
}

static float noise(float2 p) {
    float2 ip = floor(p);
    float2 fp = fract(p);
    float a = hash12(ip);
    float b = hash12(ip + float2(1, 0));
    float c = hash12(ip + float2(0, 1));
    float d = hash12(ip + 1);
    
    float2 t = smoothstep(0.0, 1.0, fp);
    return mix(mix(a, b, t.x), mix(c, d, t.x), t.y);
}

static float fbm(float2 p, int octaveCount) {
    float value = 0;
    float amplitude = 0.5;
    
    for (int i = 0; i < octaveCount; ++i) {
        value += amplitude * noise(p);
        p *= rotate2d(0.45);
        p *= 2;
        amplitude *= 0.5;
    }
    
    return value;
}

// MARK: - Main

[[ stitchable ]] half4 fbmLightning(float2 position, half4 color, float4 bounds, float iTime) {
    // Normalized pixel coordinates (from 0 to 1)
    float2 uv = position/bounds.zw;
    uv = 2 * uv - 1;
    uv.x *= bounds.z / bounds.w;

    uv += 2 * fbm(uv + 0.8*iTime, 10) - 1;
    
    float dist = abs(uv.x);
    half3 col = color.rgb * pow(mix(0.0, 0.07, hash11(iTime)) / dist, 1);
    
//    col = pow(col, 1);
    // Output to screen
    return half4(col, 1);
}
