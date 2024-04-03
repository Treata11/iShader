/*
 Vignette.metal
 iShader

 Created by Treata Norouzi on 4/3/24.
*/

#include <metal_stdlib>
using namespace metal;

[[ stitchable ]] half4 vignette(float2 position, half4 color, float4 bounds, float intensity, float percentage) {
    float2 uv = position / bounds.zw;
    uv *=  1 - uv.yx;
    
    float vig = uv.x * uv.y * intensity;
    
    vig = pow(vig, percentage);
    
    // Apply vignette effect to the color
    half4 resultColor = color * vig;  // Modulate color with vignette effect

    return half4(half3(resultColor), 1);
}

// MARK: Second Approach

/*
[[ stitchable ]] half4 vignette(float2 position, half4 color, float4 bounds) {
    float OuterVig = 1.0; // Position for the Outer vignette
    
    float InnerVig = 0.05; // Position for the inner Vignette Ring
    
    float2 uv = position / bounds.zw;
    
    float2 center = float2(0.5); // Center of Screen
    
    float dist  = distance(center,uv )*1.414213; // Distance  between center and the current Uv. Multiplyed by 1.414213 to fit in the range of 0.0 to 1.0
    
    float vig = clamp((OuterVig-dist) / (OuterVig-InnerVig), 0.0, 1.0); // Generate the Vignette with Clamp which go from outer Viggnet ring to inner vignette ring with smooth steps
    
    color *= vig; // Multiply the Vignette with the texture color
    
    return color;
}
 
 see: https://www.shadertoy.com/view/Mdsfzl
*/

