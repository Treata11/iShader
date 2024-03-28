/*
 Genera.swift
 iShader

 Created by Treata Norouzi on 2/26/24.
 
 Abstract:
 A General collection of AudioVisualization-Shaders, extended to SwiftUI.
*/

import SwiftUI

/// `BASS` framework is responsible for all the audio playback & analysis
/// which currently is only available for **iOS** & **macOS**.
#if os(iOS) || os(macOS)

public extension View {
    
    // MARK: - Audio Eclipse
    func audioEclipse(fft: [Float], time: Double) -> some View {
        self.colorEffect(
            ShaderLibrary.default.audioEclipse(
                .boundingRect,
                .float(time),
                .floatArray(fft)
            )
        )
    }
    
    // MARK: - Shades of Music
    // TODO: Add support for gestures in the shader code.
    // looks better in landScape
    func shadesOfMusic(fft: [Float], 
        time: Double, translation: CGPoint = .zero
    ) -> some View {
        self.colorEffect(
            ShaderLibrary.default.shadesOfMusic(
                .boundingRect,
                .float(time),
//                .float2(translation),
                .floatArray(fft)
            )
        )
    }
    
    // MARK: - Sine Sound Waves
    func sineSoundWaves(fft: [Float], time: Double, waveCount: Int = 7) -> some View {
        self.colorEffect(
            ShaderLibrary.default.sineSoundWaves(
                .boundingRect,
                .float(time),
                .floatArray(fft),
                .float(Float(waveCount))
            )
        )
    }
    
    // MARK: - Glowing Sound Particles
    func glowingSoundParticles(fft: [Float], time: Double) -> some View {
        self.colorEffect(
            ShaderLibrary.default.glowingSoundParticles(
                .boundingRect,
                .float(time),
                .floatArray(fft)
            )
        )
    }
    
    // MARK: - Universe Within
    // TODO: Optimize
    func universeWithin(
        fft: [Float],
        time: Double, translation: CGPoint = .zero
    ) -> some View {
        self.colorEffect(
            ShaderLibrary.default.universeWithin(
                .boundingRect,
                .float(time),
                .float2(translation),
                .floatArray(fft)
            )
        )
    }
    
    // MARK: - Galaxy Visuals
    // FIXME: There's a negative vignette applied ...
    func galaxyVisuals(fft: [Float], time: Double) -> some View {
        self.colorEffect(
            ShaderLibrary.default.galaxyVisuals(
                .boundingRect,
                .float(time),
                .floatArray(fft)
            )
        )
    }
    
    // MARK: - Round Audio Specturm
    // TODO: Optimize
    // TODO: Colorize the Capsule
    func roundAudioSpecturm(fft: [Float], rayCount: Int = 78) -> some View {
        self.colorEffect(
            ShaderLibrary.default.roundAudioSpecturm(
                .boundingRect,
                .floatArray(fft),
                .float(Float(rayCount))
            )
        )
    }
    
    // MARK: - Waves Remix
    // FIXME: Waves are too noisy
    /// Looks way better in `landScape`
    func wavesRemix(fft: [Float], time: Double) -> some View {
        self.colorEffect(
            ShaderLibrary.default.wavesRemix(
                .boundingRect,
                .float(time),
                .floatArray(fft)
            )
        )
    }
}

#endif
