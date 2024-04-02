/*
 RetroSun.metal
 iShader

 Created by Treata Norouzi on 2/13/24.

 Based on: https://www.shadertoy.com/view/4dcyW7
*/

#include <metal_stdlib>
using namespace metal;


#define tri(t, scale, shift) ( abs(t*2 - 1) - shift ) * (scale)

[[ stitchable ]] half4 retroSun(float2 position, float4 bounds, float iTime) {
    float2 R = bounds.zw,
    uv = (position - 0.5 * R) / min(R.x, R.y) + 0.5;
    // Flip Y coordinate to have the bottom-to-top convention
    uv.y = 1-uv.y;
    
    // sun
    half dist = length(uv - float2(0.5));
    half divisions = 6;
    half divisionsShift = 0.5;
    
    half pattern = tri(fract(( uv.y + 0.5) * 20.0), 2/divisions, divisionsShift)
    - (-uv.y + 0.26) * 0.85;
    half sunOutline = smoothstep(half(0), half(-0.015), max(dist - half(0.315), -pattern)) ;
   
    half3 c = sunOutline * mix(half3(4, 0, 0.2), half3(1, 1, 0), uv.y);
    
    // glow
    half glow = max(0.0, 1-dist * 1.25);
    glow = min(pow(glow, 3), half(0.325));
    c += glow * half3(1.5, 0.3, (sin(iTime)+1)) * 1.1;
    
    return half4(c, 1);
}
