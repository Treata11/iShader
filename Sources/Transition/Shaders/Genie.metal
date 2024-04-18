/*
 Genie.metal
 iShader
 
 Created by Treata Norouzi on 4/17/24.

 Based on: https://www.shadertoy.com/view/flyfRt
 License: MIT
*/

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;


static float2 remap(float2 uv, float2 inputLow, float2 inputHigh, float2 outputLow, float2 outputHigh) {
    float2 t = (uv - inputLow)/(inputHigh - inputLow);
    return mix(outputLow, outputHigh, t);
}

[[ stitchable ]] float2 genieTranstion(float2 position, float2 size, float effectValue) {
    float2 normalizedPosition = position / size;
    float positiveEffect = effectValue * sign(effectValue);
    float progress = abs(sin(positiveEffect * M_PI_2_F));

    float bias = pow((sin(normalizedPosition.y * M_PI_F) * 0.1), 0.9);

    // right side
    float BOTTOM_POS = size.x;
    // width of the mini frame
    float BOTTOM_THICKNESS = 0.1;
    // height of the min frame
    float MINI_FRAME_THICKNESS = 0.0;
    // top right
    float2 MINI_FRAME_POS = float2(size.x, 0.0);

    float min_x_curve = mix((BOTTOM_POS-BOTTOM_THICKNESS/2.0)+bias, 0, normalizedPosition.y);
    float max_x_curve = mix((BOTTOM_POS+BOTTOM_THICKNESS/2.0)-bias, 1, normalizedPosition.y);
    float min_x = mix(min_x_curve, MINI_FRAME_POS.x, progress);
    float max_x = mix(max_x_curve, MINI_FRAME_POS.x+MINI_FRAME_THICKNESS, progress);

    float min_y = mix(0.0, MINI_FRAME_POS.y, progress);
    float max_y = mix(1.0, MINI_FRAME_POS.y+MINI_FRAME_THICKNESS, progress);

    float2 modUV = remap(position, float2(min_x, min_y), float2(max_x, max_y), float2(0), float2(1));

    return position + modUV * progress;
}
