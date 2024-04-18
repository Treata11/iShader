/*
 WindowBlinds.metal
 iShader

 Created by Treata Norouzi on 4/18/24.
 
 Based on: https://gl-transitions.com/editor/windowblinds
 License: MIT
*/

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;


[[stitchable]] half4 windowBlinds(float2 position, half4 color, float2 size,
    float progress, float count = 100
) {
    float2 uv = position / size;
    
    float t = progress;
  
    if (fmod(floor(uv.y * count * progress), 2) == 0)
        t *= 2 - 0.5;
  
    return mix(
        color, 0, mix(t, progress, smoothstep(0.8, 1.0, progress))
    );
}
