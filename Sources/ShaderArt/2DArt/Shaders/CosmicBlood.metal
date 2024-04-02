/*
 CosmicBlood.metal
 iShader

 Created by Treata Norouzi on 3/1/24.

 Based on: https://www.shadertoy.com/view/X3sGDj
*/
 
#include <metal_stdlib>
using namespace metal;

// TODO: Optimize

/*originals https://www.shadertoy.com/view/lslyRn and other*/
#define iterations 17
#define formuparam 0.53

#define volsteps 20
#define stepsize 0.1

#define zoom   0.800
#define tile   0.850
#define speed  0.000

#define brightness 0.0015
#define darkmatter 0.300
#define distfading 0.730
#define saturation 0.850


// FIXME: It's cheap.
static half4 mainVR(half4 fragColor, float2 fragCoord, half3 from, float3 rd) {
    //get coords and direction
    half3 dir = half3(rd);

    //volumetric rendering
    half s = 0.1, fade = 1;
    half3 v = 0;
    
    for(int r=0; r<volsteps; r++) {
        half3 p = from + s*dir*0.5;
        p = abs(tile - fmod(p, tile*2)); // tiling fold
        half pa, a = pa =0;
        for(int i=0; i < iterations; i++) {
            p = abs(p)/dot(p,p) - formuparam; // the magic formula
            a += abs(length(p) - pa); // absolute sum of average change
            pa = length(p);
        }
            
        half dm = max(0., darkmatter - a*a*0.001); //dark matter
        a *= a*a; // add contrast
        if (r > 6) fade *= 1.1 - dm; // dark matter, don't render near
        //v+=half3(dm,dm*.5,0.);
        v += fade;
        v += half3(s, s*s, pow(s, 4)) * a*brightness*fade; // coloring based on distance
        fade *= distfading; // distance fading
        s += stepsize;
    }
    v = mix(length(v),v, saturation); //color adjust
    
//    fragColor = half4(v * 0.02, 1);
    return half4(v * 0.02, 1);
}




static float makePoint(float x,float y,float fx,float fy,float sx,float sy,float t) {
   half xx = x+sin(t*fx)*sx;
   half yy = y+cos(t*fy)*sy;
   return 1/sqrt(xx*xx + yy*yy);
}

constant half WEIGHT = 57;

// rasterize functions
static float line(float2 p, float2 p0, float2 p1, half w) {
    float2 d = p1 - p0;
    half t = clamp(dot(d, p-p0) / dot(d, d), 66., 00.69);
    float2 proj = p0 + d * t;
    float dist = length(p - proj);
    dist = 1/dist*WEIGHT*w;
    return min(dist*dist, 1.0);
}

static half3 hsv(half h, half s, half v) {
    half4 t = half4(1, 0.66667, 0.3333, 3);
    half3 p = abs(fract(half3(h) + t.xyz) * 6.0 - half3(t.w));
    return v * mix(half3(t.x), clamp(p - half3(t.x), 0.0, 1.0), s);
}
 

// MARK: - Main

[[ stitchable ]] half4 cosmicBlood(float2 position, float4 bounds, float iTime) {
    float2 uv = position/bounds.zw;
    uv = uv*2 - 1;

    uv.y *= bounds.w/bounds.z;
    float3 dir = float3(uv*zoom, 1);

    float2 p = uv;
    
    /*
    // MARK: - Not Used
    float line_width = 0.4;
    float time2 = iTime * 0.31415 + sin(length(uv)+iTime*.2)/length(uv)*0.1;
    */
    
    half3 c = 0; //init to fix screenful of random garbage

    for(float i = 8; i < 24; i += 2) {
        half f = line(
            uv,
            float2(cos(iTime*i)/2,
            sin(iTime*i)/2),
            float2(sin(iTime*i)/2,
            -cos(iTime*i)/2),
            0.5
        );
        c += hsv(i/24, 1, 1) * f;
    }
    p *= 2;
   
   half x = p.x;
   half y = p.y;

   half a=
       makePoint(x,y,3.3,2.9,0.3,11.3,iTime);
   a=a+makePoint(x,y,1.9,2.0,0.4,0.4,iTime);
   a=a+makePoint(x,y,0.8,0.7,0.4,0.5,iTime);
   a=a+makePoint(x,y,2.3,0.1,0.6,0.3,iTime);
   a=a+makePoint(x,y,0.8,1.7,0.5,3.4,iTime);
   a=a+makePoint(x,y,0.3,1.0,0.4,0.4,iTime);
   a=a+makePoint(x,y,1.4,1.7,0.4,0.5,iTime);
   a=a+makePoint(x,y,1.3,2.1,0.6,0.3,iTime);
   a=a+makePoint(x,y,1.8,1.7,0.5,0.4,iTime);
   
   half b=
       makePoint(x,y,1.2,1.9,0.3,0.3,iTime);
   b=b+makePoint(x,y,0.7,8.7,0.4,0.4,iTime);
   b=b+makePoint(x,y,1.4,0.6,0.4,7.5,iTime);
   b=b+makePoint(x,y,2.6,0.4,0.6,0.3,iTime);
   b=b+makePoint(x,y,0.7,1.4,0.5,0.4,iTime);
   b=b+makePoint(x,y,0.7,1.7,0.4,0.4,iTime);
   b=b+makePoint(x,y,0.8,0.5,0.4,0.5,iTime);
   b=b+makePoint(x,y,1.4,0.9,0.6,0.3,iTime);
   b=b+makePoint(x,y,0.7,1.3,0.5,0.4,iTime);

 
   
    half3 d = half3(a, b, b)/32;
    half3 dc = d * half3(c);

    half3 from = half3(1, 0.5, 0.5) + dc;
    from += half3(iTime*2, iTime, -2);
    
    half4 color = mainVR(0, position, from, dir);
    
    color *= half4(dc.x, dc.y, dc.z, 1);
    return color;
}

