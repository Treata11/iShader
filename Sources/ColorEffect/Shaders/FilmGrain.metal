/*
 FilmGrain.metal
 iShader

 Created by Treata Norouzi on 4/4/24.
 
 Based on: https://www.shadertoy.com/view/4sXSWs
*/

#include <metal_stdlib>
using namespace metal;


[[ stitchable ]] half4 filmGrain(float2 position, half4 color, float4 bounds, 
    float iTime, float strength, float fineGrain
) {
    float2 uv = position / bounds.zw;
    
    float x = (uv.x + 4) * (uv.y + 4) * (iTime * 10);
    half4 grain = half4(fmod((fmod(x, 13) + 1) * (fmod(x, 123) + 1), 0.01)-0.005) * strength;
    
//    if(abs(uv.x - 0.5) < 0.002)
//        color = 0;
    
    if (fineGrain == 1) {
        grain = 1 - grain;
        return color * grain;
    } else {
        return color + grain;
    }
}
