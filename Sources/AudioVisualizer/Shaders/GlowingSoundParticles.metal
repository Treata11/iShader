/*
 GlowingSoundParticles.metal
 iShader

 Created by Treata Norouzi on 2/29/24.

 Based on: https://www.shadertoy.com/view/4tt3RH
*/

#include <metal_stdlib>
using namespace metal;


#define NUM_PARTICLES 40
#define GLOW 0.4
#define TIME_SKIP 0
#define SPEED_UP 1.15
//#define MUSIC

static half3 Orb(float2 uv, half3 color, float radius, float offset, float iTime) {
    float2 position = float2(sin((1.9 + offset * 4.9) * ((iTime * SPEED_UP) + TIME_SKIP)),
                         cos((2.2 + offset * 4.5) * ((iTime * SPEED_UP) + TIME_SKIP)));
    
    position *= ((sin(((iTime * SPEED_UP) + TIME_SKIP) - offset) + 7.0) * 0.1) * sin(offset);
    
    radius = ((radius * offset) + 0.005);
    float dist = radius / distance(uv, position);
    return color * pow(dist, 1 / GLOW);
}

// MARK: - Main
[[ stitchable ]] half4 glowingSoundParticles(
   float2 position, float4 bounds, float iTime,
    device const float *iChannel, int count
) {
    float2 uv = 2 * float2(position - 0.5 * bounds.zw) / min(bounds.w, bounds.z);
    
    half3 pixel = 0;
    half3 fragColor = 0;
    
    fragColor.r = ((sin(((iTime * SPEED_UP) + TIME_SKIP) * 0.25) + 1.5) * 0.4); // 0.2 - 1.0
    fragColor.g = ((sin(((iTime * SPEED_UP) + TIME_SKIP) * 0.34) + 2.0) * 0.4); // 0.4 - 1.2
    fragColor.b = ((sin(((iTime * SPEED_UP) + TIME_SKIP) * 0.71) + 4.5) * 0.2); // 0.7 - 1.1
    
    float radius = 0.045;
    
//#ifdef MUSIC
    float beat[4];
    beat[0] = iChannel[int(0.10 * float(count))];
    beat[1] = iChannel[int(0.25 * float(count))];
    beat[2] = iChannel[int(0.40 * float(count))];
    beat[3] = iChannel[int(0.55 * float(count))];
    
    beat[0] = (beat[0] + beat[1] + beat[2] + beat[3]) * 0.25;
    radius += beat[0] / 8.0;
//#endif
    
    for (float i = 0; i < NUM_PARTICLES; i++)
        pixel += Orb(uv, fragColor, radius, i / NUM_PARTICLES, iTime);

    
//    fragColor = float4(pixel, 1.0);
    return half4(pixel, 1);
}
