/*
 SineDistortion.metal
 MetalShaders

 Created by Treata Norouzi on 4/4/24.
 
 Based on: https://www.shadertoy.com/view/4sGBz3
*/

#include <metal_stdlib>
using namespace metal;


[[ stitchable ]] float2 sineDistortion(float2 position, float2 size, float iTime, float intensity) {
    float2 uv = position / size;
    
    float sTime = iTime * 1.4;
    float uvY = uv.y * 5.2 * intensity;
    
    uv.x += cos(uvY + sTime) / 100;
    uv.y += sin(uv.x * 5.1 * intensity + sTime) / 100;
    uv.x -= cos(uvY + sTime) / 100;
    uv.x -= cos(uv.x * 5.2 * intensity + sTime) / 100;
    
    return uv*size;
}
