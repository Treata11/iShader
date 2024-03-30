/*
 TMGyroids.metal
 iShader

 Created by Treata Norouzi on 3/9/24.

 Based on: https://www.shadertoy.com/view/l3fSDr
*/

#include <metal_stdlib>
using namespace metal;


static half3 pal(float t) {
    half3 b = half3(0.45);
    half3 c = half3(0.35);
    return b + c*cos(6.28318*(t*half3(1) + half3(0.7, 0.39, 0.2)));
}

// see https://www.youtube.com/watch?v=-adHIyjIYgk
static float gyroid(float3 p, float scale, float iTime) {
    p *= scale;
    float bias = mix(1.1, 2.65, sin(iTime*0.4 + p.x/3 + p.z/4)*0.5 + 0.5);
    return abs(dot(sin(p*1.01), cos(p.zxy*1.61)) - bias)/(scale*1.5) - 0.1;
}

static float scene(float3 p, float iTime) {
    float g1 = 0.7*gyroid(p, 4, iTime);
    return g1;
}

static float3 norm(float3 p, float iTime) {
    float3x3 k = float3x3(p,p,p) - float3x3(0.01);
    return normalize(scene(p, iTime) - float3(scene(k[0], iTime) ,scene(k[1], iTime) ,scene(k[2], iTime)));
}

// MARK: - Main

[[ stitchable ]] half4 tmGyroids(
   float2 position, half4 color, float4 bounds, float iTime
) {
    float2 uv = (position - 0.5*bounds.zw) / min(bounds.z, bounds.w);
    float3 init = float3(iTime*0.25, 1.5, 0.3);
    float3 cam = normalize(float3(1, uv));

    float3 p = init;
    bool hit = false;
    for (int i = 0; i < 100 && !hit; i++) {
        if (distance(p,init) > 8.) break;
        float d = scene(p, iTime);
        if (d*d < 0.00001) hit = true;
        p += cam*d;
    }
    float3 n = norm(p, iTime);

    float ao = 1 - smoothstep(-0.3, 0.75, scene(p+n*0.4, iTime))
             * smoothstep(-3, 3, scene(p+n*1, iTime));
    
    float fres = -max(0.0, pow(0.8 - abs(dot(cam,n)), 3));
    half3 vign = smoothstep(0.0, 1, half3(1-(length(uv*0.8) - 0.1)));
    half3 col = pal(0.1 - iTime*0.01 + p.x*0.28 + p.y*0.2 + p.z*0.2);
    col = (half3(fres)+col)*ao;
    col = mix(col, half3(0), !hit ? 1 : smoothstep(0.0, 8, distance(p, init)));
    col = mix(half3(0), col, vign+.1);
    col = smoothstep(0.0, 1 + 0.3*sin(iTime+p.x*4.+p.z*4.),col);
    color.xyz = sqrt(half3(col));
    return color;
}
