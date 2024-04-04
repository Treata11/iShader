//
//  WorleyDisplacement.metal
//  MetalShaders
//
//  Created by Treata Norouzi on 4/4/24.
//
// https://www.shadertoy.com/view/4ddXR8

#include <metal_stdlib>
using namespace metal;


// Copy of https://www.shadertoy.com/view/llS3RK

//Calculate the squared length of a vector
static float length2(float2 p) { return dot(p, p); }

//Generate some noise to scatter points.
static float noise(float2 p){
    return fract(sin(fract(sin(p.x) * (43.13311)) + p.y) * 31.0011);
}

static float worley(float2 p) {
    //Set our distance to infinity
    float d = 1e30;
    //For the 9 surrounding grid points
    for (int xo = -1; xo <= 1; ++xo) {
        for (int yo = -1; yo <= 1; ++yo) {
            //Floor our float2 and add an offset to create our point
            float2 tp = floor(p) + float2(xo, yo);
            //Calculate the minimum distance for this grid point
            //Mix in the noise value too!
            d = min(d, length2(p - tp - noise(tp)));
        }
    }
    return 3.0*exp(-4.0*abs(2.5*d - 1.0));
}

static float fworley(float2 p, float iTime) {
    //Stack noise layers
    return sqrt(sqrt(sqrt(
        worley(p*5.0 + 0.05*iTime) *
        sqrt(worley(p * 50.0 + 0.12 + -0.1*iTime)) *
        sqrt(sqrt(worley(p * -10.0 + 0.03*iTime))))));
}

// MARK: - Main

[[ stitchable ]] float2 worleyDisplacement(float2 position, float2 size, float iTime, float displace) {
    float2 uv = position / size;
    //Calculate an intensity
    float t = fworley(uv * size / 1500, iTime);
    //Add some gradient
    t*=exp(-length2(abs(0.7*uv - 1)));
    
    // please keep in mind that i have no idea of maths.
    // i am sorry. but at least it looks nice.
    float2 of1 = float2(displace*t);
    float2 of2 = float2(displace)/size.xy;
    uv += of1-of2;
    uv.y -= displace*.25;
    
    return uv * size;
}

