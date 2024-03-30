/*
 HypnoticRipples.metal
 iShader

 Created by Treata Norouzi on 2/13/24.

 Based on: https://www.shadertoy.com/view/ldX3zr
*/

#include <metal_stdlib>
using namespace metal;

[[ stitchable ]] half4 hypnoticRipples(float2 position, half4 color, float4 bounds, float time) {
    const float2 center = 0.5;
    const float speed = 0.035;
    float invAr = bounds.w / bounds.z;

    float2 uv = position / bounds.zw;
        
    half3 col = half4(half2(uv), 0.5+0.5*sin(time), 1).xyz;
   
    half3 texcol;
            
    float x = (center.x - uv.x);
    float y = (center.y - uv.y) * invAr;
        
    //float r = -sqrt(x*x + y*y); //uncoment this line to symmetric ripples
    float r = -(x*x + y*y);
    float z = 1 + 0.5*sin((r + time*speed)/0.013);
    
    texcol.xyz = z;
    
    return half4(col*texcol, 1);
}

