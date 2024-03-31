/*
 ElectricField.metal
 iShader

 Created by Treata Norouzi on 2/25/24.

 Based on: https://www.shadertoy.com/view/4tySWK
*/

#include <metal_stdlib>
using namespace metal;


// TODO: Introduce Touch compatibility

#define detail_steps_ 13
#define mod3_ float3(0.1031, 0.11369, 0.13787)

static float3 hash3_3(float3 p3);
static float perlin_noise3(float3 p);
static float noise_sum_abs3(float3 p);
static float2 domain(float2 uv, float s, float4 bounds);

// MARK: - Main

[[ stitchable ]] half4 electricField(float2 position, half4 color, float4 bounds, float iTime) {
    float2 p = domain(position, 2.5, bounds);
       
    float electric_density = 0.9;
    float electric_radius  = length(p) - 0.4;
    float velocity = 0.07;
    
    float moving_coord = sin(velocity * iTime) / 0.2 * cos(velocity * iTime);
    float3  electric_local_domain = float3(p, moving_coord);
    float electric_field = electric_density * noise_sum_abs3(electric_local_domain);
    
    half3 col = half3(107, 148, 196) / 255;
    col += (1 - (electric_field + electric_radius));
    
    for (int i = 0; i < detail_steps_; i++) {
        if (length(col) >= 2.1 + float(i) / 2)
            col -= 0.3;
    }
    col += 1 - 4.2*electric_field;
    
    return half4(col, 1);
}

// MARK: - Helpers

static float3 hash3_3(float3 p3) {
    p3 = fract(p3 * mod3_);
    p3 += dot(p3, p3.yxz + 19.19);
    return -1 + 2*fract(float3((p3.x + p3.y) * p3.z, (p3.x+p3.z) * p3.y, (p3.y+p3.z) * p3.x));
}

static float perlin_noise3(float3 p) {
    float3 pi = floor(p);
    float3 pf = p - pi;
    
    float3 w = pf * pf * (3 - 2 * pf);
    
    return     mix(
        mix(
            mix(
                dot(pf, hash3_3(pi)),
                dot(pf - float3(1, 0, 0), hash3_3(pi + float3(1, 0, 0))),
                w.x),
            mix(
                dot(pf - float3(0, 0, 1), hash3_3(pi + float3(0, 0, 1))),
                dot(pf - float3(1, 0, 1), hash3_3(pi + float3(1, 0, 1))),
                w.x),
        w.z),
        mix(
            mix(
                dot(pf - float3(0, 1, 0), hash3_3(pi + float3(0, 1, 0))),
                dot(pf - float3(1, 1, 0), hash3_3(pi + float3(1, 1, 0))),
                w.x),
            mix(
                dot(pf - float3(0, 1, 1), hash3_3(pi + float3(0, 1, 1))),
                dot(pf - 1, hash3_3(pi + 1)),
                w.x),
         w.z),
    w.y);
}


static float noise_sum_abs3(float3 p) {
    float f = 0.;
    p *= 3;
    f += 1.0000 * abs(perlin_noise3(p)); p *= 2;
    f += 0.5000 * abs(perlin_noise3(p)); p *= 3;
    f += 0.2500 * abs(perlin_noise3(p)); p *= 4;
    f += 0.1250 * abs(perlin_noise3(p)); p *= 5;
    f += 0.0625 * abs(perlin_noise3(p)); p *= 6;
    
    return f;
}

static float2 domain(float2 uv, float s, float4 bounds) {
    return (2*uv-bounds.zw) / bounds.w * s * 1.1;   // 10% zoom-out
}

