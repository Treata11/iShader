/*
 GlowingMarblingBlack.metal
 iShader

 Created by Treata Norouzi on 3/16/24.

 Based on: https://www.shadertoy.com/view/WtdXR8
*/

#include <metal_stdlib>
using namespace metal;


[[ stitchable ]] half4 glowingMarblingBlack(float2 position, float4 bounds, 
    float iTime, float2 iMouse
) {
//    iMouse = max(iMouse, 1);
    float2 uv = (2*position - bounds.zw) / min(bounds.z, bounds.w);

    for (float i = 1; i < 10; i++) {
        uv.x += 0.6 / i * cos(i * 2.5 * uv.y + iTime);
        uv.y += 0.6 / i * cos(i * 1.5 * uv.x + iTime);
    }
    uv *= iMouse;   // uv *= max(iMouse, 1);
    
    return half4(half3(0.1)/abs(sin(iTime - uv.y - uv.x)), 1);
}
