/*
 GalaxyVisuals.metal
 iShader

 Created by Treata Norouzi on 3/6/24.

 Based on: https://www.shadertoy.com/view/MslGWN
*/

#include <metal_stdlib>
using namespace metal;



// http://www.fractalforums.com/new-theories-and-research/very-simple-formula-for-fractal-patterns/
static half field(float3 p, float s, float iTime) {
    half strength = 7 + 0.03 * log(1.e-6 + fract(sin(iTime) * 4373.11));
    half accum = s/4;
    half prev = 0;
    half tw = 0;
    for (int i = 0; i < 26; ++i) {
        float mag = dot(p, p);
        p = abs(p) / mag + float3(-.5, -.4, -1.5);
        float w = exp(-float(i) / 7);
        accum += w * exp(-strength * pow(abs(mag - prev), 2.2));
        tw += w;
        prev = mag;
    }
    return max(0.0, 5*accum / tw-0.7);
}

// Less iterations for second layer
static half field2(float3 p, float s, float iTime) {
    half strength = 7 + .03 * log(1.e-6 + fract(sin(iTime) * 4373.11));
    half accum = s/4;
    half prev = 0;
    half tw = 0;
    for (int i = 0; i < 18; ++i) {
        float mag = dot(p, p);
        p = abs(p) / mag + float3(-0.5, -0.4, -1.5);
        float w = exp(-float(i) / 7.);
        accum += w * exp(-strength * pow(abs(mag - prev), 2.2));
        tw += w;
        prev = mag;
    }
    return max(0.0, 5*accum / tw-0.7);
}

static float3 nrand3(float2 co) {
    float3 a = fract( cos( co.x*8.3e-3 + co.y ) * float3(1.3e5, 4.7e5, 2.9e5) );
    float3 b = fract( sin( co.x*0.3e-3 + co.y ) * float3(8.1e5, 1.0e5, 0.1e5) );
    float3 c = mix(a, b, 0.5);
    return c;
}

// MARK: - Main

[[ stitchable ]] half4 galaxyVisuals(
   float2 position, half4 color, float4 bounds, float iTime,
    device const float *iChannel, int count
) {
    float2 uv = 2*position / bounds.zw - 1;
    float2 uvs = uv * bounds.zw / max(bounds.z, bounds.w);
    float3 p = float3(uvs/4, 0) + float3(1, -1.3, 0);
    
    float3 coe = float3(sin(iTime/16), sin(iTime/12), sin(iTime/128));
    p += 0.2 * coe;
    
    half freqs[4];
    //Sound
//    freqs[0] = texture( iChannel0, float2( 0.01, 0.25 ) ).x;
//    freqs[1] = texture( iChannel0, float2( 0.07, 0.25 ) ).x;
//    freqs[2] = texture( iChannel0, float2( 0.15, 0.25 ) ).x;
//    freqs[3] = texture( iChannel0, float2( 0.30, 0.25 ) ).x;
    freqs[0] = iChannel[int(0.01 * count)];
    freqs[1] = iChannel[int(0.07 * count)];
    freqs[2] = iChannel[int(0.15 * count)];
    freqs[3] = iChannel[int(0.3 * count)];

    half t = field(p, freqs[2], iTime);
    float v = (1 - exp((abs(uv.x) - 1.) * 6)) * (1 - exp((abs(uv.y) - 1) * 6));
    
    //Second Layer
    float3 p2 = float3(uvs / (4+sin(iTime*0.11)*0.2 + sin(iTime*0.15)*0.3 + 0.6), 1.5)
        + float3(2, -1.3, -1);
    p2 += 0.25 * coe;
    half t2 = field2(p2, freqs[3], iTime);
    half4 c2 = mix(0.4, 1, v) * t2*half4(1.3 * t2*t2, 1.8*t2, freqs[0], 1);
    
    
    //Let's add some stars
    //Thanks to http://glsl.heroku.com/e#6904.0
    float2 aspect = min(bounds.z, bounds.w);
    
    float2 seed = p.xy * 2;
    seed = floor(seed * aspect);
    float3 rnd = nrand3( seed );
    float4 starcolor = float4(pow(rnd.y, 40));
    
    //Second Layer
    float2 seed2 = p2.xy * 2;
    seed2 = floor(seed2 * aspect);
    float3 rnd2 = nrand3( seed2 );
    starcolor += float4(pow(rnd2.y, 40));
    
    return mix(freqs[3]-0.3, 1, v) * half4(1.5*freqs[2] * pow(t, 3) , 1.2*freqs[1] * t*t, freqs[3]*t, 1) + c2 + half4(starcolor);
}
