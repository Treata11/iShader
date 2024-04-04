/*
 CRT.metal
 MetalShaders

 Created by Treata Norouzi on 4/4/24.

 Based on: https://www.shadertoy.com/view/ltf3WB
*/

#include <metal_stdlib>
using namespace metal;


// Will return a value of 1 if the 'x' is < 'value'
static float Less(float x, float value) {
    return 1 - step(value, x);
}

// Will return a value of 1 if the 'x' is >= 'lower' && < 'upper'
static float Between(float x, float  lower, float upper) {
    return step(lower, x) * (1 - step(upper, x));
}

//    Will return a value of 1 if 'x' is >= value
static float GEqual(float x, float value) {
    return step(value, x);
}

// MARK: - Main

[[ stitchable ]] half4 crt(float2 position, half4 color, float4 bounds,
    float xPass, float yPass
) {
    float brightness = 1.25;
    float2 uv = position / bounds.zw;
    uv.y = -uv.y;
    //uv = uv * 0.05;
    
    float2 uvStep;
    uvStep.x = uv.x / (1 / bounds.z);
    uvStep.x = fmod(uvStep.x, 3.0);
    uvStep.y = uv.y / (1.0 / bounds.w);
    uvStep.y = fmod(uvStep.y, 3.0);
    
//    half4 newColour = texture(iChannel0, uv);
    
    // Choose one of these to change the style of the crt
    if (xPass == 1 && yPass == 0) {
        color.r = color.r * Less(uvStep.x, 1);
        color.g = color.g * Between(uvStep.x, 1, 2);
        color.b = color.b * GEqual(uvStep.x, 2);
    } else if (yPass ==  1 && xPass == 0) {
        color.r = color.r * Less(uvStep.y, 1);
        color.g = color.g * Between(uvStep.y, 1, 2);
        color.b = color.b * GEqual(uvStep.y, 2);
    } else {
        color.r = color.r * step(1, (Less(uvStep.x, 1) + Less(uvStep.y, 1)));
        color.g = color.g * step(1, (Between(uvStep.x, 1, 2) + Between(uvStep.y, 1, 2)));
        color.b = color.b * step(1, (GEqual(uvStep.x, 2) + GEqual(uvStep.y, 2)));
    }
    
    return color * brightness;
}
