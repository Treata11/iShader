/*
 ShadesOfMusic.metal
 iShader

 Created by Treata Norouzi on 2/29/24.

 Based on: https://www.shadertoy.com/view/XsfGDS
*/

#include <metal_stdlib>
using namespace metal;


#define SHOW_BLOCKS = true

static half rand(float x) {
    return fract(sin(x) * 4358.5453123);
}

static half rand(float2 co) {
    return fract(sin(dot(co.xy ,float2(12.9898, 78.233))) * 43758.5357);
}

static float box(float2 p, float2 b, float r) {
  return length(max(abs(p)-b, 0.0))-r;
}

static float sampleMusic(device const float *iChannel, int count) {
    return 0.5 * (iChannel[int(0.15 * float(count))] + iChannel[int(0.3 * float(count))]);
}

// MARK: - Main
[[ stitchable ]] half4 shadesOfMusic(
   float2 position, float4 bounds, float iTime,
    device const float *iChannel, int count
) {
    const float speed = 0.7;
    const float ySpread = 1.6;
    const int numBlocks = 70;

    float pulse = sampleMusic(iChannel, count);
    
    float2 uv = position.xy / bounds.zw - 0.5;
    float aspect = bounds.z / bounds.w;
    half3 baseColor = uv.x > 0 ? half3(0, 0.3, 0.6) : half3(0.6, 0, 0.3);
    
    half3 fragColor = pulse*baseColor*0.5*(0.9-cos(uv.x*8.0));
    uv.x *= aspect;
    
    for (int i = 0; i < numBlocks; i++) {
        float z = 1.0-0.7*rand(float(i)*1.4333); // 0=far, 1=near
        float tickTime = iTime*z*speed + float(i)*1.23753;
        float tick = floor(tickTime);
        
        float2 pos = float2(0.6*aspect*(rand(tick)-0.5), sign(uv.x)*ySpread*(0.5-fract(tickTime)));
        pos.x += 0.24*sign(pos.x); // move aside
        if (abs(pos.x) < 0.1) pos.x++; // stupid fix; sign sometimes returns 0
        
        float2 size = 1.8*z*float2(0.04, 0.04 + 0.1*rand(tick+0.2));
        float b = box(uv-pos, size, 0.01);
        float dust = z*smoothstep(0.22, 0.0, b)*pulse*0.5;
        #ifdef SHOW_BLOCKS
        float block = 0.2*z*smoothstep(0.002, 0.0, b);
        float shine = 0.6*z*pulse*smoothstep(-0.002, b, 0.007);
        fragColor += dust*baseColor + block*z + shine;
        #else
        fragColor += dust*baseColor;
        #endif
    }
    
    fragColor -= rand(uv)*0.04;
//    fragColor = vec4(color, 1.0);
    
    return half4(fragColor, 1);
}
