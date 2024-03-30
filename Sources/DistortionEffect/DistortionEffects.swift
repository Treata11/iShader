/*
 DistortionEffects.swift
 iShader


 Created by Treata Norouzi on 3/30/24.
*/

import SwiftUI

/// The **DistortionEffect** Metal shader library.
@dynamicMemberLookup
public enum DistortionEffectLibrary {
    /**
     Returns a new shader function representing the `[[ stitchable ]]` **MSL**
     function called `name` in the Inferno shader library.
     
     Typically this subscript is used implicitly via the dynamic
     member syntax, for example:
     ```swift
        let fn = DistortionEffectLibrary.myFunction
     ```
     which creates a reference to the `[[ stitchable ]]` **MSL** function called
     `myFunction()`.
     */
    public static subscript(dynamicMember name: String) -> ShaderFunction {
        ShaderLibrary.bundle(Bundle.module)[dynamicMember: name]
    }
}

// MARK: - Wave

public extension View {
    /**
     A `distortionEffect()` shader that generates a wave effect, where no effect is applied on the left side of the input, and the full effect is applied on the right side.

     **Parameters:**

     - `time`: The number of elapsed seconds since the shader was created.
     - `speed`: How fast to make the waves ripple. Try starting with a value of 5.
     - `smoothing`: How much to smooth out the ripples, where greater values produce a smoother effect. Try starting with a value of 10.
     - `strength`: How pronounced to make the ripple effect. Try starting with a value of 5.
     */
    func wave(
        time: TimeInterval,
        speed: Float = 2.5,
        smoothing: Float = 10,
        strength: Float = 2.5,
        maxSampleOffset: CGSize = .zero
    ) -> some View {
        return distortionEffect(
            DistortionEffectLibrary.wave(
                .float(time),
                .float(speed),
                .float(smoothing),
                .float(strength)
            ),
            maxSampleOffset: maxSampleOffset
        )
    }
}

// MARK: - Relative Wave

public extension VisualEffect {
    /**
     A `distortionEffect()` shader that generates a wave effect, where no effect is applied on the left side of the input, and the full effect is applied on the right side.

     **Parameters:**

     - `size`: The size of the whole image, in user-space.
     - `time`: The number of elapsed seconds since the shader was created.
     - `speed`: How fast to make the waves ripple. Try starting with a value of 5.
     - `smoothing`: How much to smooth out the ripples, where greater values produce a smoother effect. Try starting with a value of 20.
     - `strength`: How pronounced to make the ripple effect. Try starting with a value of 5.
     */
    func relativeWave(
        size: CGSize,
        time: TimeInterval,
        speed: Float = 5,
        smoothing: Float = 20,
        strength: Float = 5,
        maxSampleOffset: CGSize = .zero
    ) -> some VisualEffect {
        return distortionEffect(
            DistortionEffectLibrary.relativeWave(
                .float2(size),
                .float(time),
                .float(speed),
                .float(smoothing),
                .float(strength)
            ),
            maxSampleOffset: maxSampleOffset
        )
    }
}

// MARK: - Water

public extension VisualEffect {
    /**
     A `distortionEffect()` shader that generates a water rippling effect.

     **Parameters:**

     - `size`: The size of the whole image, in user-space.
     - `time`: The number of elapsed seconds since the shader was created.
     - `speed`: How fast to make the water ripple. Ranges from 0.5 to 10 work best; try starting with 3.
     - `strength`: How pronounced the rippling effect should be. Ranges from 1 to 5 work best; try starting with 3.
     - `frequency`: How often ripples should be created. Ranges from 5 to 25 work best; try starting with 10.
     */
    func water(
        size: CGSize,
        time: TimeInterval,
        speed: Float = 3,
        strength: Float = 3,
        frequency: Float = 10,
        maxSampleOffset: CGSize = .zero
    ) -> some VisualEffect {
        return distortionEffect(
            DistortionEffectLibrary.water(
                .float2(size),
                .float(time),
                .float(speed),
                .float(strength),
                .float(frequency)
            ),
            maxSampleOffset: maxSampleOffset
        )
    }
}
