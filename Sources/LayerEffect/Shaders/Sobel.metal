/*
 Sobel.metal
 iShader

 Created by Treata Norouzi on 4/3/24.

 Based on: https://www.shadertoy.com/view/Xdf3Rf
*/

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;


// Basic sobel filter implementation
// Jeroen Baert - jeroen.baert@cs.kuleuven.be
//
// www.forceflow.be

static float intensity(half4 col) {
    return sqrt((col.x*col.x) + (col.y*col.y) + (col.z*col.z));
}

static half3 sobel(float stepx, float stepy, float2 center, SwiftUI::Layer layer) {
    // get samples around pixel
    float tleft = intensity(layer.sample(center + float2(-stepx, stepy)));
    float left = intensity(layer.sample(center + float2(-stepx, 0)));
    float bleft = intensity(layer.sample(center + float2(-stepx, -stepy)));
    float top = intensity(layer.sample(center + float2(0, stepy)));
    float bottom = intensity(layer.sample(center + float2(0, -stepy)));
    float tright = intensity(layer.sample(center + float2(stepx, stepy)));
    float right = intensity(layer.sample(center + float2(stepx, 0)));
    float bright = intensity(layer.sample(center + float2(stepx, -stepy)));
 
    // Sobel masks (see http://en.wikipedia.org/wiki/Sobel_operator)
    //        1 0 -1     -1 -2 -1
    //    X = 2 0 -2  Y = 0  0  0
    //        1 0 -1      1  2  1
    
    // You could also use Scharr operator:
    //        3 0 -3        3 10   3
    //    X = 10 0 -10  Y = 0  0   0
    //        3 0 -3        -3 -10 -3
 
    float x = tleft + 2*left + bleft - tright - 2*right - bright;
    float y = -tleft - 2*top - tright + bleft + 2*bottom + bright;
    float color = sqrt((x*x) + (y*y));
    
    return half3(color);
 }

// MARK: - Main

/// Use the `step` parameter to fiddle with settings
[[ stitchable ]] half4 sobel(float2 position, SwiftUI::Layer layer, float step) {
    
    // Unused
    // half4 color = layer.sample(position);
    
    return half4(sobel(step, step, position, layer), 1);
}
