/*
 AudioEclipse.metal
 iShader

 Created by Treata Norouzi on 2/26/24.

 Based on: https://www.shadertoy.com/view/MdsXWM
*/

#include <metal_stdlib>
using namespace metal;


/// number of lights
static constant float dots = 40;
/// radius of light ring that the lights circle on
static constant float radius = 0.25;
static constant float brightness = 0.02;

//convert HSV to RGB
static float3 hsv2rgb(float3 c) {
    float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    float3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
        
[[ stitchable ]] half4 audioEclipse(
    float2 position, float4 bounds, float iTime,
    device const float *iChannel, int count
) {
    float2 p=(position - 0.5*bounds.zw)/min(bounds.z, bounds.w);
    half3 c = half3(0, 0, 0.1); //background color
        
    for (float i=0; i < dots; i++) {
        
        // read frequency for this dot from audio input channel
        // based on its index in the circle
//        float vol =  texture(iChannel, float2(i/dots, 0.0)).x;
        /// The alternative approach in the absence of `texture` in Metal.
        int index = int((i/dots) * count);
        float vol = iChannel[index];

        float b = vol * brightness;
        
        // get location of dot
        float x = radius*cos(2*M_PI_H * float(i)/dots);
        float y = radius*sin(2*M_PI_H * float(i)/dots);
        float2 o = float2(x, y);
        
        // get color of dot based on its index in the
        // circle + time to rotate colors
        float3 dotCol = hsv2rgb(float3((i + iTime*10)/dots,1, 1));
        
        // get brightness of this pixel based on distance to dot
        c += half3(b / (length(p-o)) * dotCol);
    }
    
     // black circle overlay
//     float dist = distance(p , float2(0));
//     c = c * smoothstep(0.26, 0.28, dist);
     
    return half4(c, 1);
}
