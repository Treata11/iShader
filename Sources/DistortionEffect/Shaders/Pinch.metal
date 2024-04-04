/*
 Pinch.metal
 iShader

 Created by Treata Norouzi on 4/4/24.

 Based on: https://www.shadertoy.com/view/XlSGRw
*/

#include <metal_stdlib>
using namespace metal;


[[ stitchable ]] float2 pinch(float2 position, float2 size, float factor) {
    float2 uv = position / size;

    float2 center = float2(0.5);
    float2 dir = normalize(center - uv);
    float d = length(center - uv);
    
//    float factor = 0.5 * sin(iTime);
    float f = exp(factor * (d - 0.5)) - 1;
    if (d > 0.5) f = 0;
  
    return (uv + f * dir) * size;
}
