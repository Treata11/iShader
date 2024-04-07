/*
 FluidGradient.metal
 iShader

 Created by Treata Norouzi on 2/12/24.

 Based on: https://www.shadertoy.com/view/sld3WN
*/

#include <metal_stdlib>
using namespace metal;


static float random(float2 _st) {
    return fract(sin(dot(_st.xy*100000.+ 0.234234523, float2(12.9898, 78.233))) * 43758.5453123);
}

static float2 N22(float2 p){
    float3 a = fract(p.xyx * float3(123.34, 234.34, 345.65));
    a += dot(a, a+34.45);
    return fract(float2(a.x*a.y,a.y*a.z));

}

/*
static float3 rgb2hsl(float3 c){
    float cMin=min(min(c.r,c.g),c.b),
          cMax=max(max(c.r,c.g),c.b),
          delta=cMax-cMin;
    float3 hsl=float3(0.,0.,(cMax+cMin)/2.);
    if(delta!=0.0){ //If it has chroma and isn't gray.
        if(hsl.z<.5){
            hsl.y=delta/(cMax+cMin); //Saturation.
        }else{
            hsl.y=delta/(2.-cMax-cMin); //Saturation.
        }
        float deltaR=(((cMax-c.r)/6.)+(delta/2.))/delta,
              deltaG=(((cMax-c.g)/6.)+(delta/2.))/delta,
              deltaB=(((cMax-c.b)/6.)+(delta/2.))/delta;
        //Hue.
        if(c.r==cMax){
            hsl.x=deltaB-deltaG;
        }else if(c.g==cMax){
            hsl.x=(1./3.)+deltaR-deltaB;
        }else{ //if(c.b==cMax){
            hsl.x=(2./3.)+deltaG-deltaR;
        }
        hsl.x=fract(hsl.x);
    }
    return hsl;
}
*/
 
static half3 hsl2rgb(half3 c) {
    half3 rgb = clamp(abs(fmod(c.x * 6+half3(0, 4, 2), 6)-3)-1, 0, 1);

    return c.z + c.y * (rgb-0.5)*(1-abs(2 * c.z - 1));
}

static half3 okhsl_to_srgb(half3 hsl) {
    half3 rgb = hsl2rgb(hsl);
    
    // Convert sRGB to linear RGB
    for (int i = 0; i < 3; i++) {
        if (rgb[i] <= 0.04045) {
            rgb[i] /= 12.92;
        } else {
            rgb[i] = pow((rgb[i] + 0.055) / 1.055, 2.4);
        }
    }
    
    return rgb;
}

static half3 getColS(float2 pt, float2 uv, half3 c, float secs) {

    float r = random(pt);
    float2 n = max(N22(pt * 212.12312), 0.1);
    pt = cos((secs+1024)*n + n);
    // pt = float2(cos(secs/6. + n.x*3.14*2.),sin(secs/6. + n.y*3.14*2.));
    pt *= 0.25;
    float l = length(uv-pt);
    float s = smoothstep(0.9 , 0.0, l);
    
    half3 col = okhsl_to_srgb(half3(r, 1, 0.7));
//    float3 col2 = hsl2rgb(float3(r, 1, 0.7));
    
    //col = mix(col,col2,step(0.,uv.x));
    
    col = mix(c, col, s);
    
    return col;
}

// MARK: - fluidGradient Shader

[[ stitchable ]] half4 fluidGradient(
     float2 position, float4 bounds, float secs
) {
    half3 col = 0;
    
//    col = 1- col;
    float2 uv = (position/bounds.zw - 0.5)*2;
    uv.x *= bounds.z/bounds.w;
    
    // Responsible for the green fluid-sphere
    float2 pt = float2(0, 0.5);
    col = getColS(pt, uv, col, secs);
    // Responsible for the pink fluid-sphere
    pt = 0.5;
    col = getColS(pt, uv, col, secs);
    // Responsible for the cyan fluid-sphere
    pt = float2(0.7, -0.1);
    col = getColS(pt, uv, col, secs);
    // Responsible for the orange fluid-sphere
    pt = float2(-0.7, -0.2);
    col = getColS(pt, uv, col, secs);
    // Responsible for the purple fluid-sphere
    pt = float2(-0.3, -0.2);
    col = getColS(pt, uv, col, secs);

    return half4(col, 1);
}


/*
float2 hash(float2 p) // TODO: replace this by something better
{
    p = float2( dot(p,float2(127.1,311.7)), dot(p,float2(269.5,183.3)) );
    return -1.0 + 2.0*fract(sin(p)*43758.5453123);
}
*/
