/*
 DistortionEffects.swift
 iShader

 Created by Treata Norouzi on 3/30/24.
 
 Abstract:
 A collection of DistortionEffect-Shaders as view-modifier methods or as
 visual-effect modifiers.
*/

import SwiftUI

public extension View {
    
    // MARK: - Wave
    
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

    // MARK: - Water

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
    
    // MARK: - Sine Distortion
    
    /// Cheap
    func sineDistortion(
        size: CGSize,
        time: TimeInterval,
        intensity: Float = 2,
        maxSampleOffset: CGSize = .zero
    ) -> some VisualEffect {
        return distortionEffect(
            DistortionEffectLibrary.sineDistortion(
                .float2(size),
                .float(time),
                .float(intensity)
            ),
            maxSampleOffset: maxSampleOffset
        )
    }
    
    // MARK: - Worley Displacement
    
    func worleyDisplacement(
        size: CGSize,
        time: TimeInterval,
        displace: Float = 0.125,
        maxSampleOffset: CGSize = .zero
    ) -> some VisualEffect {
        return distortionEffect(
            DistortionEffectLibrary.worleyDisplacement(
                .float2(size),
                .float(time),
                .float(displace)
            ),
            maxSampleOffset: maxSampleOffset
        )
    }
    
    // MARK: - Barrel Distortion
    
    func barrelDistortion(
        size: CGSize,
        maxSampleOffset: CGSize = .zero
    ) -> some VisualEffect {
        return distortionEffect(
            DistortionEffectLibrary.barrelDistortion(
                .float2(size)
            ),
            maxSampleOffset: maxSampleOffset
        )
    }
    
    // MARK: - Pinch
    
    func pinch(
        size: CGSize,
        factor: Float = 0.25,
        maxSampleOffset: CGSize = .zero
    ) -> some VisualEffect {
        return distortionEffect(
            DistortionEffectLibrary.pinch(
                .float2(size),
                .float(factor)
            ),
            maxSampleOffset: maxSampleOffset
        )
    }
}
