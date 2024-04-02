/*
 WavesRemix.metal
 iShader

 Created by Treata Norouzi on 3/28/24.

 Based on: https://www.shadertoy.com/view/4ljGD1
*/

#include <metal_stdlib>
using namespace metal;


static float squared(float value) { return value * value; }

static float getAmp(float frequency,
    device const float *iChannel, int count
) {
//    return texture(iChannel, float2(frequency / 512, 0)).x;
    return iChannel[ int( count * (frequency / 512) ) ];
}

static float getWeight(float f,
    device const float *iChannel, int count
) {
    return (+ getAmp(f-2, iChannel, count) + getAmp(f-1, iChannel, count) + getAmp(f+2, iChannel, count) + getAmp(f+1, iChannel, count) + getAmp(f, iChannel, count)) / 5;
}

// MARK: - Main

[[ stitchable ]] half4 wavesRemix(
    float2 position, float4 bounds, float iTime,
    device const float *iChannel, int count
) {
    float2 uvTrue = position / bounds.zw;
    float2 uv = -1 + 2 * uvTrue;
    
    float lineIntensity;
    float glowWidth;
    half3 color = 0;
    
    for (float i = 0; i < 5; i++) {
        
        uv.y += (0.2 * sin(uv.x + i/7 - iTime * 0.6));
        
//        float fft = (texture(iChannel0, float2(uvTrue.x, 1)).x - 0.5);
        float fft = iChannel[ int( count * uvTrue.x ) ] / 50 - 0.5;
        
        float Y = uv.y + getWeight(squared(i) * 20, iChannel, count) * fft;
        
        lineIntensity = 0.4 + squared(1.6 * abs(fmod(uvTrue.x + i / 1.3 + iTime, 2) - 1));
        glowWidth = abs(lineIntensity / (150 * Y));
        color += half3(glowWidth * (2 + sin(iTime * 0.13)),
                      glowWidth * (2 - sin(iTime * 0.23)),
                      glowWidth * (2 - cos(iTime * 0.19)));
    }
    
    return half4(color, 1);
}
