/*
 Luminence.metal
 iShader

 Created by Treata Norouzi on 4/3/24.
*/

#include <metal_stdlib>
using namespace metal;


[[ stitchable ]] half4 luminence(float2 position, half4 color) {
    // sums to 1
    half3 weights = half3(0.2125h, 0.7154h, 0.0721h);
    float luminance = dot(color.rgb, weights);
    
    return half4(half3(luminance), 1);
}
