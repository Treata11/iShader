/*
 2DClouds.metal
 iShader

 Created by Treata Norouzi on 3/2/24.

 Based on: https://www.shadertoy.com/view/4tdSWr
*/

#include <metal_stdlib>
using namespace metal;


constant half cloudlight = 0.3;
constant half cloudcover = 0.2;
// .light
constant float3 skycolor1L = float3(0.2, 0.4, 0.6);
constant float3 skycolor2L = float3(0.4, 0.7, 1.0);
// .dark
constant float3 skycolor1D = float3(0.106, 0.1765, 0.3333);
constant float3 skycolor2D = float3(0.051, 0.0627, 0.16);

constant float2x2 m = float2x2(1.6,  1.2, -1.2,  1.6);

static float2 hash(float2 p) {
    p = float2(dot(p,float2(127.1, 311.7)), dot(p,float2(269.5, 183.3)));
    return -1 + 2*fract(sin(p) * 43758.5453123);
}

static float noise(float2 p) {
    const float K1 = 0.366025404; // (sqrt(3)-1)/2;
    const float K2 = 0.211324865; // (3-sqrt(3))/6;
    float2 i = floor(p + (p.x+p.y)*K1);
    float2 a = p - i + (i.x+i.y)*K2;
    float2 o = (a.x>a.y) ? float2(1, 0) : float2(0, 1); //float2 of = 0.5 + 0.5*float2(sign(a.x-a.y), sign(a.y-a.x));
    float2 b = a - o + K2;
    float2 c = a - 1 + 2*K2;
    float3 h = max(0.5-float3(dot(a, a), dot(b, b), dot(c, c) ), 0);
    float3 n = pow(h, 4)*float3( dot(a, hash(i+0)), dot(b, hash(i+o)), dot(c, hash(i+1)));
    
    return dot(n, float3(70));
}

static float fbm(float2 n) {
    half total = 0, amplitude = 0.1;
    for (int i = 0; i < 7; i++) {
        total += noise(n) * amplitude;
        n = m * n;
        amplitude *= 0.4;
    }
    return total;
}

// MARK: - Main

[[ stitchable ]] half4 clouds(float2 position, float4 bounds,
    float iTime, float cloudScale, float cloudAlpha, float windSpeed, float darkMode
) {
    half clouddark = (darkMode == 0) ? 0.5 : 0.4;
    half skytint = (darkMode == 0) ? 0.5 : 0.4;
    
    float2 p = position / min(bounds.zw, bounds.wz);
    
    float2 aspect = float2(max(bounds.z/bounds.w, bounds.w/bounds.z), 1);
    
    float2 uv = p*aspect;
    float time = iTime * windSpeed;
    float q = fbm(uv * cloudScale * 0.5);
    
    // MARK: ridged noise shape
    float r = 0;
    uv *= cloudScale;
    uv -= q - time;
    float weight = 0.8;
    for (int i=0; i<8; i++) {
        r += abs(weight*noise(uv));
        uv = m*uv + time;
        weight *= 0.7;
    }
    
    // MARK: noise shape
    float f = 0;
    uv = p*aspect;
    uv *= cloudScale;
    uv -= q - time;
    weight = 0.7;
    for (int i=0; i<8; i++) {
        f += weight*noise(uv);
        uv = m*uv + time;
        weight *= 0.6;
    }
    
    f *= r + f;
    
    // MARK: noise color
    float c = 0;
    time = iTime * windSpeed * 2;
    uv = p*aspect;
    uv *= cloudScale*2;
    uv -= q - time;
    weight = 0.4;
    for (int i=0; i<7; i++) {
        c += weight*noise( uv );
        uv = m*uv + time;
        weight *= 0.6;
    }
    
    // MARK: noise ridge color
    half c1 = 0;
    time = iTime * windSpeed * 3;
    uv = p*aspect;
    uv *= cloudScale*3;
    uv -= q - time;
    weight = 0.4;
    for (int i=0; i<7; i++) {
        c1 += abs(weight * noise(uv));
        uv = m*uv + time;
        weight *= 0.6;
    }
    
    c += c1;
    
    float3 skycolor = mix(
        (darkMode == 0) ? skycolor2L : skycolor2D,
        (darkMode == 0) ? skycolor1L : skycolor1D, p.y
    );
    float3 cloudcolor = float3(1.1, 1.1, 0.9) * clamp((clouddark + cloudlight*c), 0.0, 1.0);
   
    f = cloudcover + (cloudAlpha * f * r);
    
    float3 result = mix(skycolor, clamp(skytint * skycolor + cloudcolor, 0, 1), clamp(f + c, 0.0, 1.0));
    
    return half4(result.x, result.y, result.z, 1);
}
