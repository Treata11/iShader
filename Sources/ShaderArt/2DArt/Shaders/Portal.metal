/*
 Portal.metal
 iShader

 Created by Treata Norouzi on 2/18/24.

 Based on: https://www.shadertoy.com/view/MXl3WX
*/
 
#include <metal_stdlib>
using namespace metal;


// change show define
// 0 particles
// 1 blured lines
#define show 1


// sdf scale
//const float line = 0.003;
//const float px = 0.004;

//example
//const float line = 0.0065;
//const float px = 0.0023;

#define PORTAL_ORANGE half3(1, 0.5, 0)
#define PORTAL_BLUE half3(0, 0.5, 1)


static float hash11(half p);
static float sdEllipse(float2 p, float2 ab);

static float2x2 MD(float a) {
    half c = cos(a), s = sin(a);
    return float2x2(c, -s, s, c);
}

static float draw(float2 p, float px, float timer) {
    const float line = 0.003;
//    const float px = 0.004;
    
    const int ldraw = 15;
    const int lstep = 10;
    
    float d = sdEllipse(p, float2(0.35, 0.45));
    
    const float l = line + px * 2;
    int lid = int((d+l*0.5)/l);
    lid += lstep * int(d<-l*0.5);
    lid += (lstep+1) * int(d>-l*0.5);
    
    d = fmod(abs(d),line+px*2)-l*0.5;
    d = smoothstep(-px, px, abs(d));
    
    d = d*step(0.,float(lid))*step(float(lid),float(ldraw));
    
    lid += 2;
    float rot = timer*(0.25+(float(lid)+5.77*hash11(float(lid)*15.457))*0.45)+float(lid)*M_PI_F*0.23;
#if(show)
    rot*=2.;
    rot+=(3.+float(lid)*.75)*sin(timer*0.733+float(lid)*M_PI_F*0.35);
    //rot+=7.*cos(timer*0.712+float(lid)*M_PI_F*.63);
    float2 tp = (p*MD(rot*0.5));
    float td = smoothstep(0.,px,tp.x);
#else
    rot*=.65;
    float2 tp = (p*MD(rot*0.5));
    float td = smoothstep(0.,px,tp.x*sign(tp.y))*(smoothstep(0.,0.005+0.063*clamp(float(lid-7)/20.,0.,1.),abs(tp.y)));
#endif
    td*=1.-smoothstep(0.,0.25+0.015*float(abs(lid)),abs(tp.y));
    d*=td;
    
    return d;
}

// MARK: - MAIN

[[ stitchable ]] half4 portal(float2 position, float4 bounds, float time) {
    const float px = 0.004;
    
    float2 aspect = min(bounds.z, bounds.w);
    float2 res = bounds.zw / aspect;
    float2 uv = position / aspect-0.5*res;
    
    float d = draw(uv,px, time);
    float d2 = draw(uv,px, time*1.33 + 1.5);
    float d3 = draw(uv*1.015, px*1.015, time);
    float d4 = draw(uv*1.015, px*1.015, time*1.33 + 1.5);
    
    float db = draw(uv,px, time*1.5+5.);
    float db2 = draw(uv,px, time*1.5*1.33 + 1.5 + 5);
    float db3 = draw(uv*1.015,px*1.015, time*1.5 + 5);
    float db4 = draw(uv*1.015,px*1.015, time*1.5*1.33 + 1.5 + 5);
    
    //float dr = clamp(max(d3*d4,d*d2),0.,1.);
    //float dbr = clamp(max(db3*db4,db*db2),0.,1.);
    float dr = clamp((d3*d4+d*d2),0.,1.);
    float dbr = clamp((db3*db4+db*db2),0.,1.);
    
    half3 ca = PORTAL_ORANGE*dr;
    half3 cb = PORTAL_BLUE*dbr;
    
    half3 c = ca+cb;
    
    c = c + 0.65 * pow(c, half3(2.2));
    
    float ed = abs(sdEllipse(uv, 0.85 * float2(0.35, 0.45)));
    c *= 1-smoothstep(0.025, 0.175, ed);
    float g = 1-smoothstep(-0.1, 0.25, ed);
    g *= 0.75;
    half3 tc = 0.5 + 0.5 * cos(time*0.75 + half3(uv.xyx) * 0.5 + half3(0, 2, 4));
    
    const float g2 = g*g;
    c += g2*(mix(PORTAL_BLUE,PORTAL_ORANGE,tc.r)+ tc*0.5) + g2*(PORTAL_BLUE * d * db2 + PORTAL_ORANGE * d3 * db4);
    
    return half4(c, 1);
}

// MARK: - Helpers

static float sdEllipse(float2 p, float2 ab) {
    p = abs(p); if (p.x > p.y) {
        p = p.yx; ab = ab.yx;
    }
    
    float l = ab.y*ab.y - ab.x*ab.x;
    float m = ab.x*p.x/l; float m2 = m*m;
    float n = ab.y*p.y/l; float n2 = n*n;
    float c = (m2+n2-1)/3; float c3 = c*c*c;
    float q = c3 + m2*n2*2.0;
    float d = c3 + m2*n2;
    float g = m + m*n2;
    float co;
    
    if (d<0) {
        float h = acos(q/c3)/3.0;
        float s = cos(h);
        float t = sin(h) * sqrt(3.0);
        float rx = sqrt( -c*(s + t + 2.0) + m2 );
        float ry = sqrt( -c*(s - t + 2.0) + m2 );
        co = (ry+sign(l)*rx+abs(g)/(rx*ry)- m)/2.0;
    } else {
        float h = 2.0 * m * n * sqrt(d);
        float s = sign(q+h) * pow(abs(q+h), 1/3.0);
        float u = sign(q-h) * pow(abs(q-h), 1/3.0);
        float rx = -s - u - c*4.0 + 2.0*m2;
        float ry = (s - u)*sqrt(3.0);
        float rm = sqrt( rx*rx + ry*ry );
        co = (ry/sqrt(rm-rx)+2.0*g/rm-m)/2.0;
    }
    float2 r = ab * float2(co, sqrt(1.0 - co*co));
    
    return length(r-p) * sign(p.y-r.y);
}

static float hash11(half p) {
    p = fract(p * 0.1031);
    p *= p + 33.33;
    p *= p + p;
    
    return fract(p);
}




