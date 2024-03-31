/*
 Lightning.metal
 iShader

 Created by Treata Norouzi on 3/26/24.

 Based on: https://www.shadertoy.com/view/M3jSDc
*/

#include <metal_stdlib>
using namespace metal;


static float hash21(half2 x) {
    return fract(cos(fmod(dot(x, half2(13.9898, 8.141)), 3.142h)) * 43758.5453f);
}

static float2 hash22(float2 uv) {
    uv = float2(dot(uv, float2(127.1, 311.7)), dot(uv, float2(269.5, 183.3)));
    
    return 2 * fract(sin(uv) * 43758.5453123) - 1;
}

static half perlinNoise(float2 uv) {
    float2 iuv = floor(uv);
    float2 fuv = fract(uv);
    float2 blur = smoothstep(0, 1, fuv);
    
    float2 br = float2(1, 0);
    float2 tl = float2(0, 1);
    float2 tr = 1;
    
    float2 bln = hash22(iuv);
    float2 brn = hash22(iuv + br);
    float2 tln = hash22(iuv + tl);
    float2 trn = hash22(iuv + tr);
    
    half b = mix(dot(bln, fuv), dot(brn, fuv - br), blur.x);
    half t = mix(dot(tln, fuv - tl), dot(trn, fuv - tr), blur.x);
    half c = mix(b, t, half(blur.y));
    
    return c;
}

static half fbm(float2 uv, int octaves) {
    half value = 0;
    half ampitude  = 0.5;
    half freq = 2;
    
    for (int i = 0; i < octaves; i++) {
        value += perlinNoise(uv) * ampitude;
        uv *= freq;
        ampitude *= 0.5;
    }
    
    return value;
}

// MARK: - Main

[[ stitchable ]] half4 lightning(float2 position, half4 color, float4 bounds,
    float iTime, float2 iMouse
) {
    float2 uv = (position - bounds.zw/2) / bounds.w;
    uv += fbm(uv + iTime, 20);
    
    return half4(color.xyz * mix(0.0, 0.05, hash21(half2(iTime))) / abs(uv.x), 1);
}
