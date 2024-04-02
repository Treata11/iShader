/*
 BeamDroplet.metal
 iShader

 Created by Treata Norouzi on 2/18/24.

 Based on: https://www.pouet.net/prod.php?which=57245
*/

#include <metal_stdlib>
using namespace metal;


[[ stitchable ]] half4 beamDroplet(float2 position, float4 bounds, float time) {
    float2 r = bounds.zw,
    p = position - 0.5*r;

    float l = length(p /= r.y);
    float z = time;
    half4 color = 0;
    for (int i = 0; i < 4;) {
        z += 0.07;
        color[i++] = 0.01 / length(fract(position / r + p / l * (sin(z) + 1) * abs(sin(l * 9 - z - z))) - 0.5) / l;
    }
    
//    color.a = 1;
    return color;
}
