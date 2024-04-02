/*
 WetNeuralNetwork.metal
 iShader

 Created by Treata Norouzi on 3/1/24.

 Based on: https://www.shadertoy.com/view/dlGfWV
*/

#include <metal_stdlib>
using namespace metal;


// original shader: https://www.shadertoy.com/view/mlBXRK

static float2x2 rotate2D(float a) {
    float c = cos(a), s = sin(a);
    return float2x2(c, s, -s, c); // Transposed matrix
}

[[ stitchable ]] half4 wetNeuralNetwork(float2 position, float4 bounds, half4 color, float iTime, float2 iMouse) {
    // Normalized pixel coordinates (from 0 to 1)
    float2 uv = (position - 0.5*bounds.zw) / min(bounds.z, bounds.w);
    half3 col = 0;
    float t = iTime;
    
    float2 n = 0, q;
    float2 N = 0;
    float2 p = float2(uv) + sin(t*0.1)/10;
    float S = 10;
    float2x2 m = rotate2D(1 - iMouse.x * 0.0001);

    for (float j = 0; j++ < 30;){
      p *= m;
      n *= m;
      q = p*S + j + n + t;
      n += sin(q);
      N += cos(q)/S;
      S *= 1.2;
    }
    
    col = color.xyz*4 * pow((N.x + N.y + 0.2) + 0.005/length(N), 2.1);
    //col=pow(max(half3(0),(N.x+N.y+.5)*.1*half3(6,1,2)+.003/length(N)),half3(.45));
    
    // Output to screen
    return half4(col, 1);
}
