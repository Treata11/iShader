/*
 Gamma.metal
 iShader

 Created by Treata Norouzi on 4/3/24.
*/

#include <metal_stdlib>
using namespace metal;


[[ stitchable ]] half4 gamma(float2 position, half4 color, float percentage) {
    return pow(color, half4(percentage) * 2.2); // 0 to 2.2, by convention
}
