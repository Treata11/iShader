/*
 ExplosionCloud.metal
 iShader

 Created by Treata Norouzi on 3/13/24.

 Based on: https://www.shadertoy.com/view/ssKBzm
*/

#include <metal_stdlib>
using namespace metal;



static float2x2 rot(float a) {
    half c = cos(a), s = sin(a);
    return float2x2(c, s, -s, c); // Transposed matrix
}

static float hash21(float2 n) {
    return fract(cos(dot(n, float2(5.9898, 4.1414))) * 65899.89956);
}


static float noise(float2 n) {
    const float2 d = float2(0, 1);
    float2 b = floor(n);
    float2 f = smoothstep(0, 1, fract(n));
    return mix(mix(hash21(b), hash21(b + d.yx), f.x), mix(hash21(b + d.xy), hash21(b + d.yy), f.x), f.y);
    }

static float2 mixNoise(float2 p) {
    float epsilon = 0.968785675;
    float noiseX = noise(float2(p.x+epsilon,p.y))-noise(float2(p.x-epsilon, p.y));
    float noiseY = noise(float2(p.x,p.y+epsilon))-noise(float2(p.x, p.y-epsilon));
    return float2(noiseX, noiseY);
}

static float fbm(float2 p, float iTime) {
    float amplitude = 3;
    float total = 0;
    float2 pom = p;
    for (float i= 1.3232; i < 7.45; i++) {
        p += iTime*0.05;
        pom += iTime*0.09;
        float2 n = mixNoise(i*p * 0.3244243 + iTime * 0.131321);
        n *= rot(iTime*0.5 - (0.03456*p.x + 0.0342322*p.y) * 50);
        p += float2(n*0.5);
        total+= (sin(noise(p)*8.5)*0.55 + 0.4566)/amplitude;
        
        p = mix(pom, p, 0.5);
        
        amplitude *= 1.3;
        
        p *= 2.007556;
        pom *= 1.6895367;
    }
    return total;
}

// MARK: - Main

[[ stitchable ]] half4 explosionCloud(
   float2 position, half4 color, float4 bounds, float iTime
) {
    float2 uv = position / bounds.zw;
    uv.x *= bounds.z/bounds.w;
    uv *= 2.2;
    half _fbm = fbm(uv, iTime);
    half3 col = half3(0.212, 0.08, 0.03)/max(_fbm, half(0.0001));
    col = pow(col, half3(1.5));
    
    return half4(col, 1);
}
