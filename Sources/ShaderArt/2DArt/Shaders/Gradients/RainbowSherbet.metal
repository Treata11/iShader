/*
 RainbowSherbet.metal
 iShader

 Created by Treata Norouzi on 2/25/24.

 Based on: https://www.shadertoy.com/view/tslcD8
*/

#include <metal_stdlib>
using namespace metal;


[[ stitchable ]] half4 rainbowSherbet(float2 position, float4 bounds, float time, float2 iMouse) {
    float speed = 1;
//    float scale = 0.002;
    float2 p = (position.xy/bounds.zw- float2(0.5))*2;
    p.x *= bounds.z / bounds.w;
    p *= 0.5;
    p.x += time/2;
    //float2 p = position * scale;
    
    for (int i=1; i<10; i++){
        p.x += 0.3/ i*sin(i*3*p.y + time*speed + iMouse.x/500);
        p.y += 0.3/ i*cos(i*3*p.x + time*speed + iMouse.y/500);
    }
    //p.xy += time*10.;
        
//    float t = time*1.0;
    float gbOff = p.x;
    float gOff = 0 + p.y;
    float rOff = 0;
    float r = cos(p.x + p.y+1 + rOff)*0.5 + 0.5;
    float g = sin(p.x + p.y+1 + gbOff + gOff)*0.5+ 0.5;
    float b = (sin(p.x + p.y + gbOff) + cos(p.x + p.y + gbOff))*0.3 + 0.5;
    
    return half4(r, g, b, 1);
    // return half4(p.x, p.y, 0.0); // Lava
}
