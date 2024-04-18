/*
 Crosswarp.metal
 iShader
 
 Created by Treata Norouzi on 4/18/24.
 
 Based on: https://gl-transitions.com/editor/crosswarp
 License: MIT
*/

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;


[[stitchable]] half4 crosswarp(
    float2 position, SwiftUI::Layer layer, float2 size,
    float amount, float rightToLeft = 1
) {
    float2 uv = position / size;

    float uvX = (rightToLeft == 1) ? (1 - uv.x) : uv.x;
    
    float x = smoothstep(0, 1, amount * 2 + uvX - 1);

    return mix(layer.sample(mix(uv, float2(0.5), x) * size), 0, x);
}
