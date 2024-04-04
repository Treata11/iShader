/*
 SoftThreshold.metal
 iShader

 Created by Treata Norouzi on 4/3/24.

 Based on: https://www.shadertoy.com/view/4ssGR8
*/

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;


// TODO: Input argument instead of constants
constant float Soft = 0.001;
constant float Threshold = 0.3;

[[ stitchable ]] half4 softThreshold(float2 position, SwiftUI::Layer layer) {
    float f = Soft/2;
    float a = Threshold - f;
    float b = Threshold + f;
    
    half4 tx = layer.sample(position);
    float l = (tx.x + tx.y + tx.z) / 3;
    
    float v = smoothstep(a, b, l);
    
    return half4(v, v, v, 1);
}
