/*
 Writhe.metal
 iShader

 Created by Treata Norouzi on 4/1/24.

 Based on: https://www.shadertoy.com/view/X3SGD1
*/

#include <metal_stdlib>
using namespace metal;


// Constants responsible for the behavior of the shapes of the noise itself.
#define NoiseLacunarity 1.2
#define NoiseGain 0.83
#define NoiseOctaves 19.0
#define NoiseFlowAnimationSpeed 4.0
#define NoisePulsationAnimationSpeed 1.5

// Constants pertaining to lighting.
#define DiffuseBrightnessHarshness 20.72
#define DiffuseLightingContribution 0.3
#define SpecularShininess 72.075
#define SpeckleLightingFrequency 0.9
#define MaxSpeckleLightingContribution 0.37

// Constants pertaining to the view.
#define ZoomInFactor 0.77
#define MouseExplorationZone 1

// Constants pertaining to the resulting colors.
#define BaseColor half4(0, 0.02, 0, 1)
/// The Flesh color
#define NoiseColorAdditiveFactor half4(1.11, 0, 0.2, 0)
#define ShineColorAdditiveFactor half4(0.5, 1, 1, 0)

// Mathematical constants.
#define EulersNumberOver2 1.3591409
#define Pi 3.141592

static float2x2 CalculateRotationMatrix(float a) {
    half c = cos(a), s = sin(a);
    return float2x2(c, s, -s, c); // Transposed matrix
}

static float AperiodicSin(float x) {
    // Calculate an aperiodic sinusoidal value.
    // This enables pulsations to retain a general harmony, while also having subtle bits of variance in the motion so that it can't be easily predicted.
    return sin(EulersNumberOver2 * x + 1.04) * sin(Pi * x);
}

static float FBM(float2 uv, float iTime) {
    float2 n, q, u = uv - 0.5;
    float squaredDistanceFromCenter = dot(u, u);
    float frequency = 15.6 - (0.5 - squaredDistanceFromCenter) * 9.3;
    float amplitude = 1 / frequency;
    
    float2x2 rotation = CalculateRotationMatrix(5);

    // Perform repeated iterations of FBM-based noise, where each successive summation is weaker than the last.
    float result = 0;
    for (float i = 0.0; i < NoiseOctaves; i++) {
        // Apply experimental math, rotating the result repeatedly.
        // This is largely responsible for the motion and shape of the flesh blobs.
        u = rotation * u;
        n = rotation * n;
        float pulse = (iTime - squaredDistanceFromCenter * 1.13) * NoisePulsationAnimationSpeed;
        q = u * frequency + iTime * NoiseFlowAnimationSpeed + AperiodicSin(pulse) * 0.8 + i + n;
        
        // Apply the summation step.
        result += dot(cos(q), float2(2, cos(q.y))) * amplitude;
        
        // Jiggle around one of the position vectors.
        n -= sin(q);
        
        // Exponentially increase the frequency and decrease the amplitude.
        frequency *= NoiseLacunarity;
        amplitude *= NoiseGain;
    }
    return result;
}

static float CalculateDiffuseLight(float3 normal, float3 lightDirection) {
    // Standard diffuse lighting model. Nothing special.
    float diffuseLighting = max(dot(normal, lightDirection), 0.0);
    return pow(diffuseLighting, DiffuseBrightnessHarshness) * DiffuseLightingContribution;
}

static float CalculateSpecularLight(float maxSpeckleInfluence, float3 normal, float3 lightDirection, float3 currentPosition) {
    // Standard specular lighting model. Nothing special.
    float3 lightSource = float3(0.9, 0.1, 1);
    float3 reflectedDirection = reflect(-lightDirection, normal);
    float3 viewDirection = normalize(lightSource - currentPosition);
    float specularLighting = pow(max(dot(viewDirection, reflectedDirection), 0.0), SpecularShininess);
    
    // Found by experimentation. Adds a bit of a speckled texturing to the result.
    // Probably wouldn't generalize, but I think it looks cool with the flesh-like aesthetic of this shader.
    float speckleInfluence = pow(abs(cross(reflectedDirection, viewDirection).z), 1 / SpeckleLightingFrequency) * maxSpeckleInfluence;
    
    return specularLighting + speckleInfluence;
}

// MARK: - Main

[[ stitchable ]] half4 writhe(float2 position, float4 bounds,
    float iTime, float2 iMouse
) {
    // Calculate the mouse-based view offset.
    /*
    float2 viewOffset = 0;
    if (iMouse.z > 0)
    float2 viewOffset = (iMouse.xy - bounds.zw * 0.5) * - MouseExplorationZone;
     */
     
    // Calculate the UVs of the fragment, correcting the aspect ratio in the process.
    float2 uv = (position /*+ viewOffset*/ - bounds.zw * 0.5) / bounds.zz + 0.5;
    uv = (uv - 0.5) / ZoomInFactor + 0.5;
    
    // Modify the UVs based on the mouse position.
    float2 mouseMovement = (iMouse / bounds.zw - 0.5);
    uv += mouseMovement * clamp(0.5 / length(mouseMovement), 0.0, 1.0);
    
    // Calculate the base noise value from the FBM. This may initially be outside of the traditional 0-1 range of values.
    float noise = FBM(uv, iTime);
    float originalNoise = noise;
    
    // Clamp the noise to a 0-1 range.
    noise = clamp(noise, 0.0, 1.0);
    
    // Store the current position UVs as a vector3 instead of a vector2.
    float3 currentPosition = float3(uv, 0);
    
    // Calculate the base light values for diffuse lighting.
    float3 lightSource = float3(0.76, 0.7, -1);
    float3 lightDirection = normalize(currentPosition - lightSource);
    
    // FIXME: The dfdx, dfdy methods might be the cause of pixelated looks of the shader in iOS & mac ...
    // Calculate the normal of the current pixel based on the derivatives of the noise with respect to both spatial axes.
    float3 normal = normalize(float3(dfdx(noise), dfdy(noise), clamp(originalNoise * 0.01, 0.0, 1.0)));
    
    // Calculate brightness, using both specular and diffuse lighting models.
    float maxSpeckleInfluence = pow(0.1 / distance(uv, float2(0.5)), 1.6);
    maxSpeckleInfluence = min(maxSpeckleInfluence, MaxSpeckleLightingContribution);
    
    float brightness = CalculateDiffuseLight(normal, lightDirection) + CalculateSpecularLight(maxSpeckleInfluence, normal, lightDirection, currentPosition);
    
    // Combine the brightness and noise values into a single coherent color.
    noise += brightness;
    return half4(BaseColor + NoiseColorAdditiveFactor * noise + ShineColorAdditiveFactor * brightness);
}
