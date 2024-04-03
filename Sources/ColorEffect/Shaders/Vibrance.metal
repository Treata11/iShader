/*
 Vibrance.metal
 iShader

 Created by Treata Norouzi on 4/3/24.
*/

#include <metal_stdlib>
using namespace metal;


[[ stitchable ]] half4 vibrance(float2 position, half4 color, float percentage) {
    float average = (color.r + color.g + color.b) / 3;
    float mx = max(color.r, max(color.g, color.b));
    float amount = (mx - average) * percentage * 3 * 5;
    
    return color - (mx - color) * amount;
}
