/*
 ColorWind.metal
 iShader

 Created by Treata Norouzi on 3/16/24.

 Based on: https://www.shadertoy.com/view/XsX3zl
*/

#include <metal_stdlib>
using namespace metal;


#define RADIANS 0.017453292519943295

constant int zoom = 40;
constant float brightness = 0.975;


static float cosRange(float degrees, float range, float minimum) {
    return (((1 + cos(degrees*RADIANS)) * 0.5) * range) + minimum;
}

[[ stitchable ]] half4 colorWind(float2 position, float4 bounds, float iTime, float2 iMouse) {
    half fScale = 1.25;
    
    float2 uv = position / bounds.zw;
    float2 p = (2*position-bounds.zw) / max(bounds.z, bounds.w);
    float ct = cosRange(iTime*5, 3, 1.1);
    float xBoost = cosRange(iTime*0.2, 5, 5);
    float yBoost = cosRange(iTime*0.1, 10, 5);
    
    fScale = cosRange(iTime * 15.5, 1.25, 0.5);
    fScale += min((iMouse.x + iMouse.y)/16, 1.3); // avoiding extreme zooms
    
    for (int i=1; i<zoom; i++) {
        float _i = float(i);
        float2 newp = p;
        newp.x += 0.25 / _i * sin(_i*p.y + iTime*cos(ct)*0.5/20 + 0.005*_i) * fScale + xBoost;
        newp.y += 0.25 / _i * sin(_i*p.x + iTime*ct*0.3/40 + 0.03*half(i+15)) * fScale + yBoost;
        p = newp;
    }
    
    half3 col = half3(0.5*sin(3*p.x)+0.5, 0.5*sin(3*p.y)+0.5, sin(p.x+p.y));
    col *= brightness;
    
    // Add border
    float vigAmt = 5;
    float vignette = (1-vigAmt*(uv.y-0.5)*(uv.y-0.05))*(1-vigAmt*(uv.x-0.5)*(uv.x-0.5));
 
    // FIXME: Fix this mess here
//    float extrusion = (col.x + col.y + col.z) / 4;
//    extrusion *= 1.5;
//    extrusion *= vignette;
    
//#if os(macOS)
//    return half4(col, 1);
//#else
//    return half4(col, extrusion);
//#endif
    
    return half4(col, 1);
}
