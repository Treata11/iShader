/*
 SpiralRiders.metal
 iShader

 Created by Treata Norouzi on 3/1/24.
 
 Based on: https://www.shadertoy.com/view/3sGfD3
*/

#include <metal_stdlib>
using namespace metal;


static float2x2 rot(float a) {
    half c = cos(a), s = sin(a);
    return float2x2(c, s, -s, c); // Transposed matrix
}


static half3 render(float2 p, float iTime) {
    const float tenthOfTime = iTime*0.1;
    
    p *= rot(tenthOfTime) * (0.0002 + 0.7*pow(smoothstep(0.0, 0.5, abs(0.5-fract(iTime*0.01))), 3.0));
    p.y -= 0.2266;
    p.x += 0.2082;
    float2 ot = 100;
    
    float m = 100;

    for (int i=0; i<150; i++) {
        float2 cp = float2(p.x, -p.y);
        p = p + cp/dot(p, p) - float2(0, 0.25);
        p *= 0.1;
        p *= rot(1.5);
        
        float2 absP = abs(p);
        ot = min(ot, absP + 0.15*fract(max(absP.x, absP.y) * 0.25 + tenthOfTime + i*0.15));
        m = min(m, absP.y);
    }
    
    ot = exp(-200*ot)*2;
    m = exp(-200*m);
    return half3(ot.x, ot.y*0.5 + ot.x*0.3, ot.y) + m*0.2;
}

// MARK: - Main

[[ stitchable ]] half4 spiralRiders(
   float2 position, float4 bounds, float iTime
) {
    float2 uv = (position - bounds.zw*0.5) / min(bounds.z, bounds.w);
    float2 d = float2(0, 0.5) / bounds.zw;
    
    half3 col = render(uv, iTime) + render(uv+d.xy, iTime) + render(uv-d.xy, iTime) + render(uv+d.yx, iTime) + render(uv-d.yx, iTime);
    
    col *= 0.2;
    return half4(col, 1);
}
 

/*
// MARK: - Golfed
// https://www.shadertoy.com/view/3tycz1

// float i,z;
float3 r(float2 p, float iTime) {
    p = p * ( 2e-4 + .7*pow(.5-.5*cos(3.14*(.5-fract(iTime*.01))),3.) )
      - float2(-.2082, .2266 );
    
    float3 o = float3(1e2), a;
    for (float i=0.; i<150.; i++)
        p += p/dot(p,p) *float2(1,-1) - float2(0,.25),
        a.xy = abs( p *= 0.1 * rot(1.5) ),
        o = min( o, float3( a.y, a +0.15* fract( max(a.x,a.y)/4. + iTime*0.1 + i*.15) ));
  
    return exp(-2e2*o);
}

[[ stitchable ]] half4 spiralRiders(
   float2 position, half4 color, float4 bounds, float iTime
) {
 // z = .5-.5*cos(3.14*(.5-fract(iTime*.01)));  // cheaper to factor scaling, but + 3 chars
 // z = .0002+.7*z*z*z;                         // but compiled code should be smaller
    float2 R = bounds.zw,
         U = ( u - R*.5 ) / R.y * R(iTime*.1),
         d = float2(0,.5)/R;
    O = ( r(U) + r(U+d)+r(U-d)+r(U+d.yx)+r(U-d.yx) ) /5.
        * mat4x3(.2,2,0, .2,.6,1, .2,0,2, 1,1,0);
}
*/
