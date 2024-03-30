/*
 BaseWarpFBM.metal
 iShader

 Created by Treata Norouzi on 3/2/24.

 Based on: https://www.shadertoy.com/view/3sfczf
*/
 
#include <metal_stdlib>
using namespace metal;



constant float2x2 m = float2x2( 0.80,  0.60, -0.60,  0.80 );
constant float2x2 m2 = m*2.02;

static float noise(float2 p) {
    return sin(p.x)*sin(p.y);
}

static float fbm4(float2 p) {
    float f = 0.0;
    
    f += 0.5000*noise( p ); p *= m2;
    f += 0.2500*noise( p ); p *= m2;
    f += 0.1250*noise( p ); p *= m2;
    f += 0.0625*noise( p );
    
    return f/0.9375;
}

static float fbm6(float2 p) {
    float f = 0;
    f += 0.500000*(0.5+0.5*noise( p )); p *= m2;
    f += 0.500000*(0.5+0.5*noise( p )); p *= m2;
    f += 0.500000*(0.5+0.5*noise( p )); p *= m2;
    f += 0.250000*(0.5+0.5*noise( p )); p *= m2;
    
    return f/0.96875;
}

static float2 fbm4_2(float2 p) {
    return float2(fbm4(p), fbm4(p+float2(7.8)));
}

static float2 fbm6_2(float2 p) {
    return float2(fbm6(p+float2(16.8)), fbm6(p+float2(11.5)));
}

static float func(float2 q, float4 ron, float iTime, float2 iMouse) {
    float2 mouseMov = iMouse/5000;
    
    q += 0.03*sin( float2(0.27,0.23) * iTime + length(q)*float2(4.1,4.3));

    float2 o = fbm4_2(0.9*q) + mouseMov;

    o += 0.04*sin( float2(0.12,0.14)*iTime + length(o));

    float2 n = fbm6_2(3*o) + mouseMov;

    ron = float4( o, n );

    float f = 0.5 + 0.5*fbm4( 1.8*q + 6.0*n );

    return mix( f, f*f*f*3.5, f*abs(n.x) );
}

// MARK: - Main

[[ stitchable ]] half4 baseWarp(float2 position, half4 color, float4 bounds, 
    float iTime, float2 iMouse
) {
    float2 p = (2*position-bounds.zw) / min(bounds.z, bounds.w);
//    float e = 2/bounds.w;

    float4 on = 0;
    half f = func(p, on, iTime, iMouse);

    half4 col = half4(half3(f), (1/f)* 0.125);
    return col;
//    return half4(col.xyz, 1-col.a);
}
