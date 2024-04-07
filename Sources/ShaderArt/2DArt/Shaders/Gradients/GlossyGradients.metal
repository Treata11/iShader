/*
 GlossyGradients.metal
 iShader

 Created by Treata Norouzi on 3/16/24.

 Based on: https://shadertoy.com/view/lX2GDR
*/

#include <metal_stdlib>
using namespace metal;


[[ stitchable ]] half4 glossyGradients(float2 position, float4 bounds, float iTime, float2 iMouse) {
    float2 uv = (position * 2 - bounds.zw) / min(bounds.z, bounds.w);

    float d = -iTime * 0.5;
    float a = 0;
    for (float i = 0; i < 8; ++i) {
        a += cos(i - d - a * uv.x);
        d += sin(uv.y * i + a);
    }
    
    d += iTime * 0.5;
    half2 touchLocation = half2(iMouse/333);
    
    half3 col = half3(
      cos(half2(uv) * half2(d, a) * touchLocation) * 0.6 + 0.4,
      cos(a + d) * 0.5 * sqrt(touchLocation.x * touchLocation.y) + 0.5
    );
    col = cos(col * cos(half3(d, a, 2.5)) * 0.5 + 0.5);
    
    return half4(col, 1);
}
