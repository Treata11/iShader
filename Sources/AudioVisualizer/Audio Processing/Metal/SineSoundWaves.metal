/*
 SineSoundWaves.metal
 iShader

 Created by Treata Norouzi on 2/29/24.

 Based on: https://www.shadertoy.com/view/XsX3zS
*/

#include <metal_stdlib>
using namespace metal;


[[ stitchable ]] half4 sineSoundWaves(
   float2 position, half4 color, float4 bounds, float iTime,
    device const float *iChannel, int count, float waves
) {
    float2 uv = -1 + 2 * position.xy / bounds.zw;
    
    color = 0;

    for (float i=0; i<waves + 1; i++) {
        float freq = iChannel[int(i / waves * count)] * 7;

        float2 p = float2(uv);

        p.x += i * 0.04 + freq * 0.03;
        p.y += sin(p.x * 10 + iTime) * cos(p.x * 2) * freq * 0.2 * ((i+1) / waves);
        float intensity = abs(0.01 / p.y) * clamp(freq, 0.35, 2.0);
        color += half4(
            intensity * (i/5), 0.5 * intensity, 1.75 * intensity, 1) * (3/waves);
    }

    return color;
}
