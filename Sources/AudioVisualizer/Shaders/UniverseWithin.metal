/*
 UniverseWithin.metal
 iShader

 Created by Treata Norouzi on 3/5/24.

 Based on: https://www.shadertoy.com/view/lscczl
*/

#include <metal_stdlib>
using namespace metal;


// After listening to an interview with Michael Pollan on the Joe Rogan
// podcast I got interested in mystic experiences that people seem to
// have when using certain psycoactive substances.
//
// For best results, watch fullscreen, with music, in a dark room.
//
// I had an unused 'blockchain effect' lying around and used it as
// a base for this effect. Uncomment the SIMPLE define to see where
// this came from.
//
// Use the mouse to get some 3d parallax.


#define S(a, b, t) smoothstep(a, b, t)
#define NUM_LAYERS 4.

//#define SIMPLE


static float N21(float2 p) {
    float3 a = fract(float3(p.xyx) * float3(213.897, 653.453, 253.098));
    a += dot(a, a.yzx + 79.76);
    return fract((a.x + a.y) * a.z);
}

static float2 GetPos(float2 id, float2 offs, float t) {
    float n = N21(id+offs);
    float n1 = fract(n*10.);
    float n2 = fract(n*100.);
    float a = t+n;
    return offs + float2(sin(a*n1), cos(a*n2))*.4;
}

/*
static float GetT(float2 ro, float2 rd, float2 p) {
    return dot(p-ro, rd);
}

static float LineDist(float3 a, float3 b, float3 p) {
    return length(cross(b-a, p-a))/length(p-a);
}
*/
 
static float df_line(float2 a, float2 b, float2 p) {
    float2 pa = p - a, ba = b - a;
    float h = clamp(dot(pa,ba) / dot(ba,ba), 0.0, 1.0);
    return length(pa - ba * h);
}

static float line(float2 a, float2 b, float2 uv) {
    float r1 = 0.04;
    float r2 = 0.01;
    
    float d = df_line(a, b, uv);
    float d2 = length(a-b);
    float fade = S(1.5, 0.5, d2);
    
    fade += S(0.05, 0.02, abs(d2-0.75));
    return S(r1, r2, d)*fade;
}

static float NetLayer(float2 st, float n, float t) {
    float2 id = floor(st)+n;

    st = fract(st)-.5;
   
    float2 p[9];
    int i=0;
    for (float y=-1; y<=1; y++) {
        for (float x=-1; x<=1; x++) {
            p[i++] = GetPos(id, float2(x,y), t);
        }
    }
    
    float m = 0;
    float sparkle = 0;
    
    for(int i=0; i<9; i++) {
        m += line(p[4], p[i], st);

        float d = length(st-p[i]);

        float s = (0.005/(d*d));
        s *= S(1, 0.7, d);
        float pulse = sin((fract(p[i].x)+fract(p[i].y)+t)*5)*0.4 + 0.6;
        pulse = pow(pulse, 20.);

        s *= pulse;
        sparkle += s;
    }
    
    m += line(p[1], p[3], st);
    m += line(p[1], p[5], st);
    m += line(p[7], p[5], st);
    m += line(p[7], p[3], st);
    
    float sPhase = (sin(t+n)+sin(t*.1))*0.25 + 0.5;
    sPhase += pow(sin(t*.1)*0.5 + 0.5, 50)*5;
    m += sparkle*sPhase;//(*.5+.5);
    
    return m;
}

// MARK: - Main

[[ stitchable ]] half4 universeWithin(
   float2 position, float4 bounds, float iTime, float2 iMouse,
    device const float *iChannel, int count
) {
    float2 uv = (position-bounds.zw * 0.5) / min(bounds.z, bounds.w);
    float2 M = iMouse/bounds.zw - 0.5;
    
    float t = iTime * 0.1;
    
    half s = sin(t);
    half c = cos(t);
    float2x2 rot = float2x2(c, -s, s, c);
    float2 st = uv*rot;
    M *= rot*2.0;
    
    float m = 0;
    for (float i = 0; i < 1; i += 1/NUM_LAYERS) {
        float z = fract(t+i);
        float size = mix(15, 1, z);
        float fade = S(0, 0.6, z) * S(1, 0.8, z);
        
        m += fade * NetLayer(st*size-M*z, i, iTime);
    }
    
//    float fft  = texelFetch( iChannel0, ifloat2(.7,0), 0 ).x;
    float fft = iChannel[int(0.7*count)];
    
    float glow = -uv.y*fft*2;
   
    half3 baseCol = half3(s, cos(t*0.4), -sin(t*0.24))*0.4 + 0.6;
    half3 col = baseCol*m;
    col += baseCol*glow;
    
    #ifdef SIMPLE
    uv *= 10;
    col = half3(1)*NetLayer(uv, 0, iTime);
    uv = fract(uv);
    //if(uv.x>.98 || uv.y>.98) col += 1.;
    #else
    col *= 1-dot(uv, uv);
    t = fmod(iTime, 230);
    col *= S(0, 20, t) * S(224, 200, t);
    #endif
    
    return half4(col, 1);
}
