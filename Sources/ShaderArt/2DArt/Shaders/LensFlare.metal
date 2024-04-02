/*
 LensFlare.metal
 iShader

 Created by Treata Norouzi on 3/2/24.

 Based on: https://www.shadertoy.com/view/Xs3Bzs
*/


#include <metal_stdlib>
using namespace metal;


// Not Used
/*
static float rnd(float2 p) {
    float f = fract(sin(dot(p, float2(12.1234, 72.8392) )*45123.2));
    return f;
}
*/
 
static float rnd(float w) {
    float f = fract(sin(w)*1000);
 return f;
}

static float regShape(float2 p, int N) {
    float f;
    
    
    float a = atan(p.x / p.y) + 0.2;
    float b = 6.28319/float(N);
    f = smoothstep(0.5, 0.51, cos(floor(0.5 + a/b)*b-a) * length(p.xy));
    
    
    return f;
}

static half3 circle(float2 p, float size, float decay, half3 color, half3 color2, float dist, float2 mouse) {
    //l is used for making rings.I get the length and pass it through a sinwave
    //but I also use a pow function. pow function + sin function , from 0 and up, = a pulse, at least
    //if you return the max of that and 0.0.
    
    float l = length(p + mouse*(dist*4)) + size/2;
    
    //l2 is used in the rings as well...somehow...
    // Not used right now
//    float l2 = length(p + mouse*(dist*4.))+size/3;
    
    ///these are circles, big, rings, and  tiny respectively
    float c = max(0.01-pow(length(p + mouse*dist), size*1.4), 0.0)*50.;
    float c1 = max(0.001-pow(l-0.3, 1/40)+sin(l*30), 0.0)*3.;
    float c2 =  max(0.04/pow(length(p-mouse*dist/2 + 0.09)*1., 1.), 0.0)/20.;
    float s = max(0.01-pow(regShape(p*5 + mouse*dist*5 + 0.9, 6) , 1.), 0.0)*5.;
    
       color = 0.5+0.5*sin(color);
    color = cos(half3(0.44, 0.24, 0.2)*8 + dist*4)*0.5 + 0.5;
    half3 f = c*color ;
    f += c1*color;
    
    f += c2*color;
    f +=  s*color;
    
    return f-0.01;
}

/*
static float sun(float2 p, float2 mouse) {
    float f;
    
    float2 sunp = p+mouse;
    float sun = 1.0-length(sunp)*8.;
    return f;
}
*/
 
// MARK: - Main

[[ stitchable ]] half4 lensFlare(float2 position, float4 bounds,
    float iTime, float2 iMouse
) {
    float aspect = min(bounds.z/bounds.w, bounds.w/bounds.z);
    
    float2 uv = position / bounds.zw-0.5;
    //uv=uv*2.-1.0;
    uv.x *= aspect;
    
    float2 mm = iMouse/bounds.zw - 0.5;
    mm.x *= aspect;
    
    
    half3 circColor = half3(0.9, 0.2, 0.1);
    half3 circColor2 = half3(0.3, 0.1, 0.5);
    
    //now to make the sky not black
    half3 col = mix(half3(0), half3(0), uv.y)*3 - 0.52*sin(iTime/0.4)*0.1 + 0.2;
    
    //this calls the function which adds three circle types every time through the loop based on parameters I
    //got by trying things out. rnd i*2000. and rnd i*20 are just to help randomize things more
    for(float i = 0; i < 10; i++){
        col += circle(uv, pow(rnd(i*2000), 2)+1.41, 0, circColor+i , circColor2+i, rnd(i*20.)*3 + 0.2-0.5, mm);
    }
    //get angle and length of the sun (uv - mouse)
    float a = atan(uv.y-mm.y / uv.x-mm.x);
    
    // not used right now
//    float l = max(1.0-length(uv-mm)-0.84, 0.0);
    
    float bright = 0.1;//+0.1/1/3.;//add brightness based on how the sun moves so that it is brightest
    //when it is lined up with the center
    
    //add the sun with the frill things
    float a9 = a*9;
    float cosA9 = cos(a9);
    col += max(0.1/pow(length(uv-mm)*5, 5), 0.0)*abs(sin(a*5+cosA9))/20;
    col += max(0.1/pow(length(uv-mm)*10, 1/20), 0.0)+abs(sin(a*3+cosA9)) / 8*(abs(sin(a9)));

    //add another sun in the middle (to make it brighter)  with the20color I want, and bright as the numerator.
    col += (max(bright/pow(length(uv-mm)*4, 1/2), 0.0)*4) * half3(0.2, 0.21, 0.3)*4;
       // * (0.5+.5*sin(float3(0.4, 0.2, 0.1) + float3(a*2., 00., a*3.)+1.3));
        
    //multiply by the exponetial e^x ? of 1.0-length which kind of masks the brightness more so that
    //there is a sharper roll of of the light decay from the sun.
    col *= exp(1 - length(uv-mm)) / 5;
    return half4(col, 0.5);
}
