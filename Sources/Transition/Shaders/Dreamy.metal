/*
 Dreamy.metal
 iShader

 Created by Treata Norouzi on 4/18/24.
 
 Based on: https://gl-transitions.com/editor/Dreamy
*/

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;


static float2 offset(float progress, float x) {
    float shifty = 0.03*progress * cos(10 * (progress + x));
    
    return float2(0, shifty);
}

[[stitchable]] half4 dreamy(float2 position, SwiftUI::Layer layer, float2 size, float progress) {
    float2 uv = position / size;
    
    return mix(layer.sample(size * (uv + offset(progress, uv.x))), 0, progress);
}
