/*
 NeonRug.metal
 iShader

 Created by Treata Norouzi on 2/24/24.

 Based on: https://www.shadertoy.com/view/mtyGWy
*/

#include <metal_stdlib>
using namespace metal;


// https://iquilezles.org/articles/palettes/
static half3 palette(float t) {
    half3 a = 0.5;
    half3 b = 0.5;
    half3 c = 1;
    half3 d = half3(0.263, 0.416, 0.557);

    return a + b*cos(6.28318 * (c*t + d));
}

// MARK: - Main

// https://www.shadertoy.com/view/mtyGWy
[[ stitchable ]] half4 neonRug(float2 position, float4 bounds, 
    float time, float neonEffect
) {
    float2 uv = (position * 2 - bounds.zw) / min(bounds.z, bounds.w);
    float2 uv0 = uv;
    half3 finalColor = 0;
    
    for (float i = 0; i < 4; i++) {
        uv = fract(uv * 1.5) - 0.5;

        float d = length(uv) * exp(-length(uv0));

        half3 col = palette(length(uv0) + i*0.4 + time*0.4);

        d = sin(d*8 + time)/8;
        d = abs(d);

        d = pow(0.01 / d, 1.2);
        
        if (neonEffect == 0) {
            d = smoothstep(0.0, 1.0, d);  // eliminate aliasing/eliminate neon effect
        }

        finalColor += col * d;
    }
        
    return half4(finalColor, 1);
}
