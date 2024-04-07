/*
 CrumpledWave.metal
 iShader

 Created by Treata Norouzi on 3/1/24.

 https://www.shadertoy.com/view/3ttSzr
*/

#include <metal_stdlib>
using namespace metal;


[[ stitchable ]] half4 crumpledWave(float2 position, half4 color, float4 bounds, float iTime) {
    float2 uv =  (2 * position - bounds.zw) / min(bounds.z, bounds.w);
   
    for (float i = 1; i < 8; i++){
        uv.y += i * 0.1 / i *
            sin(uv.x * i * i + iTime * 0.5) * sin(uv.y * i * i + iTime * 0.5);
    }
    
    color.r  = uv.y - 0.1;
    color.g = uv.y + 0.3;
    color.b = uv.y + 0.95;
    
    return color;
}
