/*
 LightbulbScreen .metal
 iShader

 Created by Treata Norouzi on 4/4/24.
 
 Based on: https://www.shadertoy.com/view/MdsXRB
*/

#include <metal_stdlib>
using namespace metal;


[[ stitchable ]] half4 lightbulbScreen(float2 position, half4 color, float4 bounds, float bulbCount) {
    float2 uv = position/bounds.zw;
//    o = texture(iChannel0,u);
    uv *= bounds.zw/bounds.w;
    
    uv.x -= 0.5 * floor(fmod(bulbCount * uv.y + 0.5, 2))/bulbCount;
    float2 u0 = floor(uv*bulbCount + 0.5)/bulbCount;
    float d = length(uv - u0)*bulbCount;
    
    return smoothstep(color, half4(0), half4(d));
}
