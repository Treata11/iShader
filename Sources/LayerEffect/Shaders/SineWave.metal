/*
 SineWave.metal
 iShader

 Created by Treata Norouzi on 4/4/24.
 
 Based on: https://www.shadertoy.com/view/MsX3DN
*/

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;


[[ stitchable ]] half4 sineWave(float2 position, SwiftUI::Layer layer, float4 bounds, float iTime, float intensity) {
    // Get the UV Coordinate of your texture or Screen Texture
    float2 uv = position / bounds.zw;
    
    // Modify that X coordinate by the sin of y to oscillate back and forth up in this.
    uv.x += sin(uv.y*intensity + iTime) / intensity;
    
    return layer.sample(uv * bounds.zw);
}
