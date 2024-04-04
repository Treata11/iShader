/*
 TileableWaterCaustic.metal
 iShader

 Created by Treata Norouzi on 4/4/24.

 Based on: https://www.shadertoy.com/view/ltSczG
 
 Abstract:
 Copied from shader by Dave_Hoskins and added distortion of background image.
*/

#include <metal_stdlib>
using namespace metal;


#define TAU 6.28318530718
#define MAX_ITER 5

[[ stitchable ]] half4 tileableWaterCaustic(float2 position, half4 color, float4 bounds,
    float iTime, float showTiling
) {
    float time = iTime * 0.5 + 23;
    // uv should be the 0-1 uv of texture...
    float2 uv = position.xy / bounds.zw;
    
    float2 p;
    if (showTiling == 1) {
        p = fmod(uv*TAU*2, TAU) - 250;
    } else {
        p = fmod(uv*TAU, TAU) - 250;
    }
    
    float2 i = float2(p);
    float c = 1;
    float inten = 0.005;

    for (int n = 0; n < MAX_ITER; n++) {
        float t = time * (1 - (3.5 / float(n+1)));
        i = p + float2(cos(t - i.x) + sin(t + i.y), sin(t - i.y) + cos(t + i.x));
        c += 1 / length(float2(p.x / (sin(i.x+t)/inten), p.y / (cos(i.y+t)/inten)));
    }
    c /= float(MAX_ITER);
    c = 1.17-pow(c, 1.4);
    
    half3 colour = half3(pow(abs(c), 8.0));
    colour = clamp((colour + half3(0.0, 0.35, 0.5))*1.2, 0.0, 1.0);
    

    #ifdef SHOW_TILING
    // Flash tile borders...
    float2 pixel = 2 / bounds.zw;
    uv *= 2;

    float f = floor(mod(iTime*.5, 2.0));     // Flash value.
    float2 first = step(pixel, uv) * f;               // Rule out first screen pixels and flash.
    uv  = step(fract(uv), pixel);                // Add one line of pixels per tile.
    colour = mix(colour, half3(1.0, 1.0, 0.0), (uv.x + uv.y) * first.x * first.y); // Yellow line
    #endif
    
    // added distortion of background image
    float2 coord = position.xy / bounds.zw;
    
    // perterb uv based on value of c from caustic calc above
    float2 tc = float2(cos(c) - 0.75, sin(c) - 0.75)*0.04;
    coord = clamp(coord + tc, 0.0, 1.0);

//    fragColor = texture(iChannel0, coord);
    // give transparent pixels a color
    if (color.a == 0) color = half4(1);
    
    return half4(colour * color.rgb, 1);
}
