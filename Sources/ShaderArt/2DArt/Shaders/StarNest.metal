/*
 StarNest.metal
 iShader

 Created by Treata Norouzi on 2/25/24.

 by Pablo Roman Andrioli
 Based on: https://www.shadertoy.com/view/XlfGRj
*/

#include <metal_stdlib>
using namespace metal;


#define iterations 17
#define formuparam 0.53

#define volsteps 20
#define stepsize 0.1

#define zoom   0.800
#define tile   0.850
#define speed  0.010

#define brightness 0.0015
#define darkmatter 0.300
#define distfading 0.730
#define saturation 0.850

static float2x2 rot(float a) {
    half c = cos(a), s = sin(a);
    return float2x2(c, s, -s, c); // Transposed matrix
}

// MARK: - Main

/// Optimization required
[[ stitchable ]] half4 starNest(float2 position, float4 bounds, float iTime, float2 iMouse) {
    //get coords and direction
    float2 uv = position / bounds.zw - 0.5;
    uv.y *= bounds.w / bounds.z;
    
    float3 dir = float3(uv*zoom, 1);
    float time = iTime * speed + 0.25;

    //mouse rotation
    float a1 = 0.5+iMouse.x / bounds.z*0.2;
    float a2 = 0.8+iMouse.y / bounds.w*0.2;

    float2 dirRot1 = dir.xz * rot(a1);
    float2 dirRot2 = dir.xy * rot(a2);
    dir.xz = dirRot1;
    dir.xy = dirRot2;

    float3 from = float3(1, 0.5, 0.5);
    from += float3(time*2, time, -2);
    
    float2 fromRot1 = from.xz * rot(a1);
    float2 fromRot2 = from.xy * rot(a2);
    from.xz = fromRot1;
    from.xy = fromRot2;
    
    //volumetric rendering
    half s = 0.1, fade = 1;
    float3 v = float3(0);
    for (int r = 0; r < volsteps; r++) {
        float3 p = from + s * dir*0.5;
        p = abs(float3(tile) - fmod(p, float3(tile*2))); // tiling fold
        
        half pa = 0;
        float a = 0;
        for (int i = 0; i < iterations; i++) {
            p = abs(p) / dot(p, p)-formuparam; // the magic formula
            
            half lengthP = length(p);
            a += abs(lengthP - pa); // absolute sum of average change
            pa = lengthP;
        }
        
        half a2 = a*a;
        half dm = max(0.0, darkmatter - a2 * 0.001); //dark matter
        a *= a2; // add contrast
        if (r > 6) fade *= 1-dm; // dark matter, don't render near
        
        v += float3(dm, dm*0.5, 0);   // Comment out & see the differences
        v += fade;
        
        half s2 = s*s;
        v += float3( half3(s, s2, s2*s2) ) * a * brightness * fade; // coloring based on distance
        fade *= distfading; // distance fading
        s += stepsize;
    }
    v = float3( mix(half3(length(v)), half3(v), half3(saturation)) ); //color adjust
    
    return half4(half3(v * 0.01), 1);
}
