/*
 Fireworks.metal
 iShader

 Created by Treata Norouzi on 3/12/24.

 Based on:https://www.shadertoy.com/view/lscGRl
*/

#include <metal_stdlib>
using namespace metal;


// "Fireworks" by Martijn Steinrucken aka BigWings - 2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define TWOPI 6.283185307179586
#define S(x,y,z) smoothstep(x,y,z)
#define B(x,y,z,w) S(x-z, x+z, w)*S(y+z, y-z, w)
#define saturate(x) clamp(x, 0, 1)

#define NUM_EXPLOSIONS 1
#define NUM_PARTICLES 66


// Noise functions by Dave Hoskins
#define MOD3 float3(0.1031, 0.11369, 0.13787)
static half3 hash31(float p) {
   float3 p3 = fract(float3(p) * MOD3);
   p3 += dot(p3, p3.yzx + 19.19);
   return half3( fract(float3((p3.x + p3.y)*p3.z, (p3.x+p3.z)*p3.y, (p3.y+p3.z)*p3.x)) );
}
/*
static float hash12(float2 p){
    float3 p3  = fract(float3(p.xyx) * MOD3);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.x + p3.y) * p3.z);
}
*/
/*
static float circ(float2 uv, float2 pos, float size) {
    uv -= pos;
    
    size *= size;
    return S(size*1.1, size, dot(uv, uv));
}
*/
 
static half light(float2 uv, float2 pos, float size) {
    uv -= pos;
    
    size *= size;
    return half(size / dot(uv, uv));
}

static half3 explosion(float2 uv, half2 p, float seed, float t) {
    
    half3 col = 0;
    
    half3 en = half3( hash31(seed) );
    half3 baseCol = en;
    for (int i=0; i<NUM_PARTICLES; i++) {
        half3 n = half3( hash31(i) ) - 0.5;
       
        half2 startP = p - half2(0, t*t * 0.1);
        half2 endP = startP + half2( normalize(n.xy)*n.z );
        
        
        float pt = 1 - pow(t-1, 2);
        half2 pos = mix(p, endP, half2(pt));
        half size = mix(0.01, 0.005, S(0, 0.1, pt));
        size *= S(1, 0.1, pt);
        
        float sparkle = (sin((pt+n.z)*100)* 0.5 + 0.5);
        sparkle = pow(sparkle, float(pow( en.x, half(3)) ) * 50)*mix(0.01, 0.01, float(en.y*n.y));
      
        //size += sparkle*B(.6, 1., .1, t);
        size += sparkle * B(en.x, en.y, en.z, half(t));
        
        col += baseCol*light(uv, float2(pos), size);
    }
    
    return half3(col);
}

static half3 Rainbow(half3 c, float iTime) {
    float avg = (c.r + c.g + c.b) / 3;
    c = avg + (c-avg)*sin(half3(0, 0.333, 0.666)+iTime);
    
    c += sin(half3(0.4, 0.3, 0.3)*iTime + half3(1.1244, 3.43215, 6.435))*half3(0.4, 0.1, 0.5);
    
    return half3(c);
}

// MARK: - Main

[[ stitchable ]] half4 fireWorks(float2 position, float4 bounds, float iTime) {
    float2 uv = position / bounds.zw;
    uv.x -= 0.5;
    uv.x *= bounds.z/bounds.w;
    
//    float n = hash12(uv+10);
    float t = iTime*0.5;
    
    half3 c = 0;
    
    for (int i=0; i<NUM_EXPLOSIONS; i++) {
        half et = t + i*1234.45235;
        half id = floor(et);
        et -= id;
        
        half2 p = hash31(id).xy;
        p.x -= 0.5;
        p.x *= 1.6;
        c += explosion(uv, p, id, et);
    }
    c = Rainbow(c, iTime);
    
    return half4(c, 1);
}
