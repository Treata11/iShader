/*
 ModFan.metal
 iShader

 Created by Treata Norouzi on 3/14/24.

 Based on: https://www.shadertoy.com/view/l3j3DK
*/

#include <metal_stdlib>
using namespace metal;


[[ stitchable ]] half4 modFan(
   float2 position, half4 color, float4 bounds, float iTime
) {
    float2 uv = position/bounds.zw, uv1 = fmod(uv, uv.x/uv.y), uv2 = fmod(uv, uv.y/uv.x);
    float4 o = float4(
        mix(
            (float3(.8,.5,.4)+float3(.2,.4,.2)*cos(6.38*(float3(2.,1.,1.)*sin(iTime*1.1+length(mix(uv1, uv2, sin(iTime)*.5+.5))*2.)*.5+.5+float3(.0,.3,.3))))*float3(uv, sin(iTime*1.2)*.5+.5)
            ,float3(0),
            length(uv1-uv2)-.5)
        ,1);
    
    return half4(o);
}
