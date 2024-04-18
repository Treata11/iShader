/*
 Morph.metal
 iShader

 Created by Treata Norouzi on 4/18/24.
 
 Based on: https://gl-transitions.com/editor/morph
 License: MIT
*/

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;


[[stitchable]] half4 morph(float2 position, SwiftUI::Layer layer, float2 size,
    float progress, float strength = 0.1
) {
    float2 uv = position / size;
    
    float4 ca = float4(layer.sample(position));
  
    float2 oa = (((ca.rg + ca.b)*0.5)*2 - 1);
    float2 ob = (((0 + 0)*0.5)*2 - 1);
    float2 oc = mix(oa, ob, 0.5)*strength;
  
    float w0 = progress;
    
    return mix(layer.sample(size * (uv + oc*w0)), 0, progress);
}
