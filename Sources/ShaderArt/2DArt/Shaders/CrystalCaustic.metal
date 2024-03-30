/*
 CrystalCaustic.metal
 iShader

 Created by Treata Norouzi on 2/13/24.

 Based on:https://www.shadertoy.com/view/XtGyDR
*/
 
#include <metal_stdlib>
using namespace metal;

static half3 MIX(half3 x, half3 y) {
    return abs(x-y);
}

static float CV(half3 c, float2 uv, float4 bounds) {
    float size = 640/bounds.w * 0.003;
    
    return 1 - clamp(size*(length(float2(c.xy) - uv)- c.z), 0.0, 1.0);
}

// MARK: - Main

[[ stitchable ]] half4 crystalCaustic(float2 position, half4 color, float4 bounds, float time) {
    half4 col = half4(0, 0, 0, 1);
    
    for (float i = 0; i < 60; i += 4.5) {
        half3 c = half3(
            sin(i*0.57 + 7 + time*0.7), sin(i*0.59 - 15 - time*0.65), sin(i*0.6 + time*0.9)
        ) * 0.75 + 0.75;
        
        col.rgb = MIX(
            col.rgb,
            c * CV(
                   half3(
                         sin(time*0.5 + i/4.5)*(bounds.z/2 -60)+bounds.z/2,
                         sin(time*0.73 + i/3)*(bounds.w/2 -60)+bounds.w/2, 0
                    ),
                position, bounds
            )
        );
    }
    
    return col;
}
