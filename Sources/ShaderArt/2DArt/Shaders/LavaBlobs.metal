/*
 LavaBlobs.metal
 iShader

 Created by Treata Norouzi on 3/5/24.

 Based on: https://www.shadertoy.com/view/3sySRK
*/

#include <metal_stdlib>
using namespace metal;


static float opSmoothUnion( float d1, float d2, float k ) {
    float h = clamp( 0.5 + 0.5*(d2-d1)/k, 0.0, 1.0 );
    return mix( d2, d1, h ) - k * h *(1-h);
}

static float sdSphere( float3 p, float s ) {
  return length(p)-s;
}

static float map(float3 p, float iTime) {
    float d = 2;
    for (int i = 0; i < 16; i++) {
        float fi = float(i);
        float time = iTime * (fract(fi * 412.531 + 0.513) - 0.5) * 2;
        d = opSmoothUnion(
            sdSphere(p + sin(time + fi * float3(52.5126, 64.62744, 632.25)) * float3(2, 2, 0.8), mix(0.5, 1.0, fract(fi * 412.531 + 0.5124))),
            d,
            0.4
        );
    }
    return d;
}

static float3 calcNormal( float3 p, float iTime ) {
    const float h = 1e-5; // or some other value
    const float2 k = float2(1, -1);
    return normalize( k.xyy*map( p + k.xyy*h, iTime ) +
                      k.yyx*map( p + k.yyx*h, iTime ) +
                      k.yxy*map( p + k.yxy*h, iTime ) +
                      k.xxx*map( p + k.xxx*h, iTime ) );
}

// MARK: - Main

[[ stitchable ]] half4 lavaBlobs(
   float2 position, half4 color, float4 bounds, float iTime
) {
    float2 uv = position / bounds.zw;
    
    // screen size is 6m x 6m
    float3 rayOri = float3((float2(uv) - 0.5) * float2(bounds.z/bounds.w, 1) * 6, 3);
    float3 rayDir = float3(0, 0, -1);
    
    float depth = 0;
    float3 p;
    
    for (int i = 0; i < 64; i++) {
        p = rayOri + rayDir * depth;
        half dist = map(p, iTime);
        depth += dist;
        if (dist < 1e-6) {
            break;
        }
    }
    
    depth = min(6.0, depth);
    float3 n = calcNormal(p, iTime);
    half b = max(0.0, dot(n, float3(0.577)));
    float3 col = (0.5 + 0.5 * cos((b + iTime * 3) + uv.xyx * 2 + float3(0, 2, 4))) * (0.85 + b * 0.35);
    col *= exp( -depth * 0.15 );
    
    // maximum thickness is 2m in alpha channel
    return half4(half3(col), 1 - (depth - 0.5) / 2);
}
