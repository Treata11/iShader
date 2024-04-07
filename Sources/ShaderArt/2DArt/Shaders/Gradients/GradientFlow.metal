/*
 GradientFlow.metal
 iShader

 Created by Treata Norouzi on 2/18/24.
*/

#include <metal_stdlib>
using namespace metal;


#define S(a, b, t) smoothstep(a, b, t)

static float2x2 rot(float a) {
    half c = cos(a), s = sin(a);
    return float2x2(c, -s, s, c);
}

static float2 hash(float2 p) {
    p = float2(dot(p, float2(2127.1, 81.17)), dot(p, float2(1269.5, 283.37)));
    return fract(sin(p) * 43758.5453);
}

static float noise(float2 p) {
    float2 i = floor(p);
    float2 f = fract(p);
    
    float2 u = f*f*(3 - 2*f);

    float n = mix(mix(dot(-1 + 2*hash(i), f),
                        dot(-1 + 2*hash(i + float2(1, 0)), f - float2(1, 0)), u.x),
                   mix(dot(-1 + 2*hash(i + float2(0, 1)), f - float2(0, 1)),
                        dot(-1 + 2*hash(i + 1), f - 1), u.x), u.y);
    return 0.5 + 0.5*n;
}

// MARK: - main

[[ stitchable ]] half4 gradientFlow(
    float2 position, float4 bounds, float time,
    device const half4 *colors, int count
) {
    float2 uv = position / bounds.zw;
    float ratio = bounds.z / bounds.w;

    float2 tuv = uv;
    tuv -= 0.5;

    // rotate with Noise; Notice: change the time's coefficient to change the speed of rotations
    float degree = noise(float2(time * 0.05, tuv.x * tuv.y));

    tuv.y *= 1/ratio;
    tuv *= rot((degree-0.5)*12.5663706 + M_PI_F);
    tuv.y *= ratio;

    // Wave warp with sin
    float frequency = 5;
    float amplitude = 30;
    float speed = time / 2;
    tuv.x += sin(tuv.y * frequency + speed) / amplitude;
    tuv.y += sin(tuv.x * frequency*1.5 + speed) / (amplitude*0.5);
    
// FIXME: It's only limited to an array of 4 colors ...
    // draw the image
    half4 layer1 = mix(colors[0], colors[1], S(-0.3, 0.2, (tuv*rot(-0.0872665)).x));
    half4 layer2 = mix(colors[2], colors[3], S(-0.3, 0.2, (tuv*rot(-0.0872664626)).x));

    return mix(layer1, layer2, S(0.5, -0.3, tuv.y));
}

/*
 Drawing constants:
 
 -0.0872665  ~  -5 * (pi/180)
 12.5663706  ~  720 * (pi/180)
 */
