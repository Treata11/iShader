/*
 BarrelDistortion.metal
 iShader

 Created by Treata Norouzi on 4/4/24.
 
 Based on: https://www.shadertoy.com/view/MlSXR3
 
 Abstract:
 Demonstrates Brown-Conrady barrel distortion as well as a trig-heavy variant,
 for illustration only.
*/

#include <metal_stdlib>
using namespace metal;


static float2 brownConradyDistortion(float2 uv) {
    // positive values of K1 give barrel distortion, negative give pincushion
    float barrelDistortion1 = 0.15; // K1 in text books
    float barrelDistortion2 = 0.0; // K2 in text books
    float r2 = uv.x * uv.x + uv.y * uv.y;
    uv *= 1 + barrelDistortion1 * r2 + barrelDistortion2 * r2 * r2;
    
    // tangential distortion (due to off center lens elements)
    // is not modeled in this function, but if it was, the terms would go here
    return uv;
}

/*
 Unused
 
// some shaders implement barrel distortion like this, but it's more expensive
// by far
static float2 easyBarrelDistortion(float2 uv) {
    float demoScale = 1.1;
    uv *= demoScale;
    float th = atan(uv.x / uv.y);
    float barrelDistortion = 1.2;
    float r = pow(sqrt(uv.x*uv.x + uv.y*uv.y), barrelDistortion);
    uv.x = r * sin(th);
    uv.y = r * cos(th);
    
    return uv;
}
*/
 
// MARK: - Main

[[ stitchable ]] float2 barrelDistortion(float2 position, float2 size) {
    float2 uv = position / size;
//    uv.y = 1 - uv.y;
    uv = uv * 2 - 1;

    uv = brownConradyDistortion(uv);

    uv = 0.5 * (uv * 0.5 + 1);
    
    return uv * size;
}
