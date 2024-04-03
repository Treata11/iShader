/*
 NightVision.metal
 iShader

 Created by Treata Norouzi on 4/3/24.
 
 Based on: https://www.shadertoy.com/view/XlsGzs
*/

#include <metal_stdlib>
using namespace metal;


[[ stitchable ]] half4 nightVision(float2 position, half4 color, float4 bounds, float iTime) {
    float2 uv = position / bounds.zw;
    
    float distanceFromCenter = length(uv - float2(0.5));
    
    float vignetteAmount;
    
    float lum;
    
    vignetteAmount = 1.0 - distanceFromCenter;
    vignetteAmount = smoothstep(0.1, 1.0, vignetteAmount);
    
    // luminance hack, responses to red channel most
    lum = dot(color.rgb, half3(0.85, 0.30, 0.10));
    
    color.rgb = half3(0.0, lum, 0.0);
    
    // scanlines
    color += 0.1*sin(uv.y*bounds.z*2);
    
    // screen flicker
    color += 0.005 * sin(iTime*16);
    
    // vignetting
    color *= vignetteAmount * 1.0;
    
    return color;
}
