/*
 Exposure.metal
 iShader

 Created by Treata Norouzi on 4/3/24.
*/

#include <metal_stdlib>
using namespace metal;


[[ stitchable ]] half4 exposure(float2 position, half4 color, float percentage) {
    return color * pow(2.0, percentage);
}
