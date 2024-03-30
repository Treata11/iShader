/*
 PulsatingFlesh.metal
 iShader

 Created by Treata Norouzi on 3/1/24.
 
 Based on: https://www.shadertoy.com/view/X3BGD1
*/

#include <metal_stdlib>
using namespace metal;


// Modify variables that affect how the scene looks.
#define ITERATIONS 28.
#define FREQUENCY_MULTIPLIER 1.18
#define DIFFUSE_STRENGTH 20.
#define SPECULAR_SHININESS 50.
#define DIFFUSE_FRESNEL_BIAS 1.
#define SPECULAR_FRESNEL_BIAS 4.
#define FLUID_STRENGTH 0.5
#define ROTATION 5.
#define LURCHINIESS 1.5
#define SPEED 2.

// Modify lighting colors.
#define AMBIENT_COLOR half3(1., 0.05, 0.2) * 0.02
#define DIFFUSE_COLOR half3(1., 0.0, 0.2)
#define DIFFUSE_HIGHLIGHT_COLOR half3(1., 0.35, 0.2) * 1.
#define SPECULAR_COLOR half3(1., 0.8, 0.8) * 0.4
#define FRESNEL_COLOR half3(1., 0.05, 0.2)

// Toggle texture/lighting features.
#define USE_FLUID false
#define USE_DIFFUSE true
#define USE_DIFFUSE_HIGHLIGHTS true
#define USE_SPECULAR_HIGHLIGHTS true
#define USE_FRESNEL true
#define USE_AMBIENT true

static float2x2 RM2D(float a) {
    half c = cos(a), s = sin(a);
    return float2x2(c, s, -s, c); // Transposed matrix
}

static float aperiodicSin(float x) {
    float eOver2 = 1.3591409;
    return sin(eOver2 * x + 1.04) * sin(M_PI_H * x);
}

// Creates freaky shapes.
static float FBM(float2 uv, float iTime) {
    float2 n, q, u = float2(uv-.5);
    float centeredDot = dot(u,u);
    float frequency = 15. - (0.5 - centeredDot) * 8.0;
    float result = 0.;
    float2x2 matrix = RM2D(ROTATION);

    for (float i = 0.; i < ITERATIONS; i++)
    {
        u = matrix * u;
        n = matrix * n;
        q = u * frequency + iTime * SPEED + aperiodicSin(iTime * LURCHINIESS -centeredDot * 1.2) * 0.4 * LURCHINIESS + i + n;
        result += dot(cos(q) / frequency, float2(2., 2.));
        n -= sin(q);
        frequency *= FREQUENCY_MULTIPLIER;
    }
    return result;
}

static float CalculateDiffuseLight(float3 normal, float3 lightDirection) {
    float maxBrightness = 0.3;
    return pow(max(dot(normal, lightDirection), 0.0), DIFFUSE_STRENGTH) * maxBrightness;
}

static float CalculateSpecularLight(float3 normal, float3 lightDirection, float3 currentPosition) {
    float3 lightSource = float3(0.9, 0.1, 1.0);
    float3 reflectedDirection = reflect(-lightDirection, normal);
    float3 viewDirection = normalize(lightSource - currentPosition);
    return pow(max(dot(viewDirection, reflectedDirection), 0.0), SPECULAR_SHININESS);
}

// MARK: - Main

[[ stitchable ]] half4 pulsatingFlesh(float2 position, half4 color, float4 bounds, 
    float iTime, float2 iMouse
) {
    // Calculate the UVs of the fragment, correcting the aspect ratio in the process.
    float2 uv = (position - bounds.zw * 0.5) / bounds.zz + 0.5;
    uv = (uv - 0.5) * 2.2 * 0.5 + 0.5;
    
    // Modify the UVs based on the mouse position.
    float2 mouseMovement = (iMouse / bounds.zw - 0.5);
    uv += mouseMovement * clamp(0.2 / length(mouseMovement) + 0.2, 0., 1.);

    // Calculate the base noise value from the FBM. This may initially be outside of the traditional 0-1 range of values.
    float noise = FBM(uv, iTime);
    float originalNoise = noise;
    
    // Clamp the noise to a 0-1 range.
    noise = clamp(noise, 0.0, 1.0);
    // Store the current position UVs as a vector3 instead of a vector2.
    float3 currentPosition = float3(uv, 1.);
    
    // Calculate the base light values for diffuse lighting.
    float3 lightSource = float3(0.76, 0.7, 0.);
    float3 lightDirection = normalize(currentPosition - lightSource);
    
    // Calculate fluid noise values that give texture to the dark parts of the texture.
    if (USE_FLUID) {
        float fluidNoise = pow(float(color.x), 5.5 * FLUID_STRENGTH) * 0.27;
        
        noise += fluidNoise * smoothstep(0.4, 0.0, noise);
    }
    
    // Calculate the normal of the current pixel based on the derivatives of the noise with respect to both spatial axes.
    float3 normal = normalize(float3(dfdx(noise), dfdy(noise), clamp(originalNoise * 0.01, 0., 1.)));
    

    // Calculate brightness, using both specular and diffuse lighting models.
    float brightness = CalculateDiffuseLight(normal, lightDirection);// + CalculateSpecularLight(normal, lightDirection, currentPosition);
    
    // Schlick Fresnel
    lightSource = float3(0.9, 0.1, 1.0);
    float3 viewDirection = normalize(lightSource - currentPosition);
    float3 fresnelNormal = normal;
    fresnelNormal.xz *= 1.;
    fresnelNormal = normalize(fresnelNormal);
    float base = 1. - dot(viewDirection, fresnelNormal);
    float exponential = pow(base, 0.2);
    float R = exponential + DIFFUSE_FRESNEL_BIAS * (1. - exponential);
    R *= 0.05;
    half3 fresnel = FRESNEL_COLOR * clamp(R, 0.04, 1.);
    
    // More fresnel but for the specular highlights.
    base = 1 - clamp(dot(viewDirection, reflect(-lightDirection, normal)), 0., 1.);
    exponential = pow(base, 0.2);
    R = exponential + SPECULAR_FRESNEL_BIAS * (1.0 - exponential);
            
    // Combine the brightness and noise values into a single coherent color.
    if (USE_DIFFUSE)
        noise += brightness;
    
//    half4 fragColor = half4(layer.sample(position));
    color = 0;
    
    // Add them all to the final color.
    color = half4(noise * DIFFUSE_COLOR.r, DIFFUSE_COLOR.g, noise * DIFFUSE_COLOR.b, 1.0);
    if (USE_DIFFUSE_HIGHLIGHTS)
        color += half4(DIFFUSE_HIGHLIGHT_COLOR * brightness, 0);
    if (USE_SPECULAR_HIGHLIGHTS)
        color += half4(SPECULAR_COLOR * CalculateSpecularLight(normal, lightDirection, currentPosition), 1) * R;
    if (USE_FRESNEL)
        color += half4(fresnel, 1);
    if (USE_AMBIENT)
        color += half4(AMBIENT_COLOR, 1);
    
    return color;
}
