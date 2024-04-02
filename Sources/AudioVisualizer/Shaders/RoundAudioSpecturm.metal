/*
 RoundAudioSpecturm.metal
 iShader

 Created by Treata Norouzi on 3/14/24.

 Based on: https://www.shadertoy.com/view/ldtBRN
*/

#include <metal_stdlib>
using namespace metal;


//static float4 rectangle(float4 color, float4 background, float4 region, float2 uv);
static half4 capsule(half4 color, half4 background, float4 region, float2 uv);
static float2 rotate(float2 point, float2 center, float angle);
static half4 bar(half4 color, half4 background, float2 position, float2 diemensions, float2 uv);
//static float4 rays(float4 color, float4 background, float2 position, float radius, float rays, float ray_length, sampler2D sound, float2 uv);
static half4 rays(half4 color, half4 background, float2 position, float radius, float rays, float ray_length, device const float *iChannel, int count, float2 uv);

// MARK: - Main

[[ stitchable ]] half4 roundAudioSpecturm(
   float2 position, float4 bounds, half4 bgColor,
    device const float *iChannel, int count,
    float rayCount
) {
    //Prepare UV and background
    float aspect = bounds.z / bounds.w;
    float2 uv = position/bounds.zw;
    uv.x *= aspect;
    
    // the first to halves are the background color
    /*
    color = mix(half4(0, 1, 0.8, 1), half4(0, 0.3, 0.25, 1), distance(float2(aspect/2, 0.5), uv));
    */
     
    float RADIUS = 0.4; //max circle radius
    float RAY_LENGTH = 0.3; //ray's max length //increased by 0.1
    
    bgColor = rays(half4(1), bgColor, float2(aspect/2, 0.5), RADIUS, rayCount, RAY_LENGTH, iChannel, count, uv);
    
    return bgColor;
}

// MARK: - Helpers

static half4 rays(half4 color, half4 background, float2 position, float radius, float rays, float ray_length, device const float *iChannel, int count, float2 uv) {
    float inside = (1 - ray_length) * radius; //empty part of circle
    float outside = radius - inside; //rest of circle
    float circle = 2*M_PI_F*inside; //circle lenght
    
    for (int i = 1; float(i) <= rays; i++) {
//        float len = outside * texture(sound, float2(float(i)/rays, 0)).x; //length of actual ray
        float len = outside * iChannel[int(count * float2(float(i)/rays).x)]; //length of actual ray
        
        background = bar(color, background, float2(position.x, position.y+inside), float2(circle/(rays*2), len), rotate(uv, position, 360/rays*float(i))); //Added capsules
    }
    
    return half4(background); //output
}

static half4 bar(half4 color, half4 background, float2 position, float2 diemensions, float2 uv) {
    return half4( capsule(color, background, float4(position.x, position.y+diemensions.y/2, diemensions.x/2, diemensions.y/2), uv) ); //Just transform rectangle a little
}

static half4 capsule(half4 color, half4 background, float4 region, float2 uv) { //capsule
    if (uv.x > (region.x-region.z) && uv.x < (region.x+region.z) &&
       uv.y > (region.y-region.w) && uv.y < (region.y+region.w) ||
       distance(uv, region.xy - float2(0, region.w)) < region.z ||
       distance(uv, region.xy + float2(0, region.w)) < region.z)
        return color;
    
    return background;
}

static float2 rotate(float2 point, float2 center, float angle) {   //rotating point around the center
    float s = sin(angle);
    float c = cos(angle);
    
    point.x -= center.x;
    point.y -= center.y;
    
    half x = point.x * c - point.y * s;
    half y = point.x * s + point.y * c;
    
    point.x = x + center.x;
    point.y = y + center.y;
    
    return point;
}
