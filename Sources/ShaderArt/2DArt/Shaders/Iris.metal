/*
 Iris.metal
 iShader

 Created by Treata Norouzi on 3/3/24.

 Based on: https://www.shadertoy.com/view/lsfGRr
*/

#include <metal_stdlib>
using namespace metal;


static float hash(float n) {
    return fract(sin(n) * 43758.5453);
}

static float noise(float2 x) {
    float2 i = floor(x);
    float2 f = fract(x);

    f = f*f*(3 - 2*f);

    float n = i.x + i.y*57;

    return mix(mix( hash(n+ 0), hash(n+ 1),f.x),
               mix( hash(n+57), hash(n+58),f.x),f.y);
}

static float fbm(float2 p) {
    const float2x2 m = float2x2(0.80,  0.60, -0.60,  0.80);
    
    float f = 0;
    f += 0.50000*noise( p ); p = m*p*2.02;
    f += 0.25000*noise( p ); p = m*p*2.03;
    f += 0.12500*noise( p ); p = m*p*2.01;
    f += 0.06250*noise( p ); p = m*p*2.04;
    f += 0.03125*noise( p );
    
    return f/0.984375;
}

static float length2(float2 p) {
    float2 q = pow(p, 4);
    return pow( q.x + q.y, 1/4);
}

// MARK: - Main

[[ stitchable ]] half4 iris(float2 position, float4 bounds, half4 irisColor,
    float iTime, half4 corneaEdgeHue
) {
    float2 p = (2*position-bounds.zw) / min(bounds.z, bounds.w);

    // polar coordinates
    float r = length(p);
    float a = atan(p.y / p.x);

    // animate
    r *= 1 + 0.1*clamp(1-r, 0.0, 1.0)*sin(iTime*0.75);

    // iris (blue-green)
    half3 col = irisColor.rgb;
    float f = fbm(5*p);
    col = mix(col, half3(0.2, 0.5, 0.4), f);
    
    // yellow towards center
    col = mix( col, corneaEdgeHue.rgb, 1-smoothstep(0.2, 0.6, r) );

    // darkening
    f = smoothstep( 0.4, 0.9, fbm( float2(15*a, 10*r) ) );
    col *= 1 - 0.5*f;

    // distort
    a += 0.05*fbm(20*p);

    // cornea
    f = smoothstep( 0.3, 1.0, fbm( float2(20*a, 6*r) ) );
    col = mix(col, 1, f);

    // edges
    col *= 1 - 0.25*smoothstep(0.6,0.8,r);

    // highlight
    f = 1 - smoothstep(0.0, 0.6, length2(
            float2x2(0.6, 0.8, -0.8, 0.6) * (p - float2(0.3, 0.5)) * float2(1, 2)
        )
    );
    col += half3(1, 0.9, 0.9)*f*0.985;
    
    // shadow
    col *= half3(0.8 + 0.2*cos(r*a));

    // pupil
    f = 1 - smoothstep(0.2, 0.25, r);
    col = mix(col, half3(0), f);

    // crop
    f = smoothstep(0.79, 0.82, r);
    col = mix(col, half3(1), f);

    // vignetting
    float2 q = position/bounds.zw;
    col *= 0.5 + 0.5*pow(16 * q.x * q.y * (1-q.x)*(1-q.y), 0.1);

    return half4(col, 1);
}
