/*
 Gradientify.metal
 iShader

 Created by Treata Norouzi on 2/11/24.
*/

#include <metal_stdlib>
using namespace metal;

// A simple shader that rotates colors over time.
// For this to work, the shader needs to know the size of the view it's shading, and the current time.

[[ stitchable ]] half4 gradientify(float2 position, float4 boundingRect, float secs) {
    // The first step, which is a common one, is to normalise the coordinates from 0 to 1, as thats far easier to work with than something like 233,122, and most of the math you'll end up doing is based on percentages.
    // Normalised pixel coords from 0 to 1
    // Gives us something like (0.4, 0,2)
    float2 uv = position / boundingRect.zw;
    
    // Calculate color as a function of the position & time
    // Start from 0.5 to brighten the colors ( we don't want this to be dark )
    // The rest of the color components should be a percentage of whatever is left of 0.5.
    // To make this brighter, increase the first value.
    float3 col = 0.5 + 0.5 *cos(secs + float3(uv.xyx) + float3(0, 2, 4));
    /*
     We start with 0.5 to say that the colors should be at least a medium grey. 0.5 as a float3, converted to RGB, would be 127.5, 127.5, 127.5. If we returned just that, we'd get a kinda grey screen.

     Next, we work out how much color to mix in to our base value. To do this, we start with secs to essentially "push" the values along, then add the xyx from our uv, which is a float3 from our base uv.

     Finally, we add (0, 2, 4) to slightly tint the whole thing to lean a little more to specific colors.
     */
    
    return half4(half3(col), 1);
}
