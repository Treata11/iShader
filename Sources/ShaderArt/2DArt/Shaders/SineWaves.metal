/*
 SineWaves.metal
 iShader

 Created by Treata Norouzi on 2/18/24.

 Based on: https://www.shadertoy.com/view/DtXfDr
*/

#include <metal_stdlib>
using namespace metal;


#define S smoothstep

static half4 Line(float2 uv, float speed, float height, half3 col, float time) {
    uv.y += S(1, 0, abs(uv.x)) * sin(time * speed + uv.x * height) * 0.2;
    
    return half4(
        S(0.06 * S(0.2, 0.9, abs(uv.x)), 0, abs(uv.y) - 0.004) * col, 1) * S(1, 0.3, abs(uv.x)
    );
}

[[ stitchable ]] half4 sineWaves(float2 position, float4 bounds, half4 color,
    float time, float count
) {
    float2 uv = (position - .5 * bounds.zw) / min(bounds.z, bounds.w);
    half4 O = 0;
    for (float i = 0; i <= count; i += 1) {
        float t = i / 5;
        O += Line(uv, 1 + t, 4 + t, half3(color.r + t*0.7, color.g + t*0.4, color.b), time);
    }
    
    return O;
}
