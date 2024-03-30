/*
 Singularity.metal
 iShader

 Created by Treata Norouzi on 3/14/24.

Based on: https://www.shadertoy.com/view/XXBGDt
*/

#include <metal_stdlib>
using namespace metal;


#define CIRCLE_RADIUS 0.5
#define CIRCLE_SMOOTHNESS 0.4

static half3 palette( float t ) {
    half3 a = half3(0.5, 0.5, 0.5);
    half3 b = half3(0.5, 0.5, 0.5);
    half3 c = half3(1.0, 1.0, 1.0);
    half3 d = half3(0.263, 0.416, 0.557);

    return a + b*cos(6.28318 * (c*t + d));
}

// 3D Noise - from https://www.shadertoy.com/view/XsGyzR
static float3 random3(float3 st) {
    st = float3( dot(st, float3(127.1, 311.7, 211.2)),
                dot(st, float3(269.5, 183.3, 157.1)), dot(st,float3(269.5, 183.3, 17.1))  );
       return -1.0 + 2.0*fract(sin(st)*43758.5453123);
}

static float noise(float3 st) {
    float3 i = floor(st) ;
    float3 f = fract(st);
        
    float3 u = smoothstep(0.,1.,f);
    
    float valueNowxy01 =mix( mix( dot( random3(i + float3(0.0,0.0,0.0) ), f - float3(0.0,0.0,0.0) ),
                                  dot( random3(i + float3(1.0,0.0,0.0) ), f - float3(1.0,0.0,0.0) ), u.x),
                        mix( dot( random3(i + float3(0.0,1.0,0.0) ), f - float3(0.0,1.0,0.0) ),
                                   dot( random3(i + float3(1.0,1.0,0.0) ), f - float3(1.0,1.0,0.0) ), u.x), u.y);
    float valueNowxy02 =mix( mix( dot( random3(i + float3(0.0,0.0,1.0) ), f - float3(0.0,0.0,1.0) ),
                                  dot( random3(i + float3(1.0,0.0,1.0) ), f - float3(1.0,0.0,1.0) ), u.x),
                        mix( dot( random3(i + float3(0.0,1.0,1.0) ), f - float3(0.0,1.0,1.0) ),
                                   dot( random3(i + float3(1.0,1.0,1.0) ), f - float3(1.0,1.0,1.0) ), u.x), u.y);

    return abs(mix(valueNowxy01, valueNowxy02, u.z));

}


static float sdCircle( float2 p, float r, float s) {
    float c = length(p);
    c = smoothstep(r-s,r,c);
    c = abs(1.-c);
    return c;
}

static float2 normalizeLength(float2 noiseUV, float2 uv, float scale) {
    float currLength = length(noiseUV);
    float2 uvOutput = float2(noiseUV.x *2/ currLength, noiseUV.y*2 / currLength);
    
    uv*=scale;
    float mixVal = clamp(0.,1.,sdCircle(uv, CIRCLE_RADIUS*scale, CIRCLE_SMOOTHNESS*scale));
    return mix(uvOutput, uv, mixVal);
}

// MARK: - Main

[[ stitchable ]] half4 singularity(
   float2 position, half4 color, float4 bounds, float iTime
) {
    // Normalized pixel coordinates (from 0 to 1)
    float2 uv = (position*2 - bounds.zw) / min(bounds.z, bounds.w);

    //Circle
    float c = sdCircle(uv, CIRCLE_RADIUS, CIRCLE_SMOOTHNESS);
    
    //Noise
    float timeFlow = iTime*0.3;
    float noiseScale = 2.0;
    float2 noiseUV = uv;
    noiseUV = normalizeLength(noiseUV,uv, noiseScale);
    float noiseTex = noise(float3(noiseUV,timeFlow));
    noiseTex = smoothstep(0.1, 0.8, noiseTex);
    
    float stepsBloom = 10.;
    c*=noiseTex;
    
    for (float i = 1; i<stepsBloom; i++) {
        float stepCircle = sdCircle(uv, CIRCLE_RADIUS+(1.9*(i/stepsBloom)),CIRCLE_SMOOTHNESS);
        
        stepCircle*= abs(1.-(i/stepsBloom));
        stepCircle*=noiseTex;
        c+=stepCircle;
    }
    

    half3 col =palette(length(noiseUV)) * c;
    
    // Output to screen
    return half4(col, 1);
    //fragColor = float4(float3(noiseUV),1.0);
}
