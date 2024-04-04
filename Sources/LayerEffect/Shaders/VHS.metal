/*
 VHS.metal
 iShader

 Created by Treata Norouzi on 4/2/24.

 Based on: https://www.shadertoy.com/view/XtBXDt
*/

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;


static half3 tex2D(SwiftUI::Layer _tex, float2 _p, float4 bounds) {
    half3 col = _tex.sample(_p).rgb;
    
    if (0.5 < abs((_p.x/bounds.z) - 0.5)) {
        col = half3(0.1);
    }
    
    return col;
}

static float hash( float2 _v ){
    return fract(sin(dot(_v, float2(89.44, 19.36))) * 22189.22);
}

static float iHash(float2 _v, float2 _r ){
    float h00 = hash(float2(floor(_v * _r + float2(0)) / _r));
    float h10 = hash(float2(floor(_v * _r + float2(1, 0)) / _r));
    float h01 = hash(float2(floor(_v * _r + float2(0, 1)) / _r));
    float h11 = hash(float2(floor(_v * _r + float2(1)) / _r));
    float2 ip = float2(smoothstep(float2(0), float2(1), fmod(_v*_r, 1)));
    
    return (h00 * (1 - ip.x) + h10 * ip.x) * (1 - ip.y) + (h01 * (1 - ip.x) + h11 * ip.x) * ip.y;
}

static float noise(float2 _v){
    float sum = 0;
    for (int i = 1; i < 9; i++) {
        float pow2i = pow(2, float(i));
        sum += iHash(_v + float2(i), float2(2 * pow2i)) / pow2i;
    }
    
    return sum;
}

// MARK: - Main

[[ stitchable ]] half4 vhs(float2 position, SwiftUI::Layer layer, float4 bounds, float iTime) {
    float2 uv = position / bounds.zw;
//    float2 uvn = uv;
    float2 pn = position;
    half3 col = 0;

    float speedTime = iTime * 10;
    
    // tape wave
    pn.x += (noise(float2(pn.y, iTime)) - 0.5)* 0.005;
    pn.x += (noise(float2(pn.y * 100, speedTime)) - 0.5) * 0.01;

    // tape crease
    float tcPhase = clamp((sin(pn.y * 8 - iTime * M_PI_F * 1.2) - 0.92) * noise(float2(iTime)), 0.0, 0.01) * 10;
    float tcNoise = max(noise(float2(pn.y * 100, speedTime)) - 0.5, 0.0);
    pn.x = pn.x - tcNoise * tcPhase;

    // switching noise
    float snPhase = smoothstep(0.03, 0.0, pn.y);
    pn.y += snPhase * 0.3;
    pn.x += snPhase * ((noise(float2(uv.y * 100, speedTime)) - 0.5) * 0.2);
    
    col = tex2D(layer, pn, bounds);
    col *= 1 - tcPhase;
    col = mix(col, col.yzx, snPhase);

  // bloom
    for (float x = -4; x < 2.5; x += 1) {
        col.xyz += half3(
            tex2D(layer, pn + float2(x - 0, 0) * 7E-3, bounds).x,
            tex2D(layer, pn + float2(x - 2, 0) * 7E-3, bounds).y,
            tex2D(layer, pn + float2(x - 4, 0) * 7E-3, bounds).z
        ) * 0.1;
    }
    col *= 0.6;

  // ac beat
    col *= 1 + clamp(noise(float2(0, uv.y + iTime * 0.2)) * 0.6 - 0.25, 0.0, 0.1);

    return half4(col, 1);
}
