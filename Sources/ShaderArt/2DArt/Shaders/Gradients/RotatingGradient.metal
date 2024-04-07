/*
 RotatingGradient.metal
 iShader

 Created by Treata Norouzi on 2/11/24.
 
 Abstract:
 A LinearGradient-shader that rotates over time.
*/

#include <metal_stdlib>
using namespace metal;

/**
 A linear-gradient that rotates over time
 */
[[ stitchable ]] half4 rotatingGradient(float2 position, float4 bounds,
    float secs,
    half4 startColor,
    half4 endColor
) {
    float currentAngle = secs;
    // Normalized pixel coordinates (from 0 to 1)
    float2 uv = position / bounds.zw;
    
    float2 origin = float2(0.5, 0.5);
    uv -= origin;
    
    float angle = M_PI_2_F - currentAngle + atan2(uv.y, uv.x);
    
    float len = length(uv);
    uv = float2(cos(angle) * len, sin(angle) * len) + origin;
    
    return half4(mix(startColor, endColor, smoothstep(0.0, 1.0, uv.x)));
}
