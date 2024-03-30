/*
 AudioVisualizers.swift
 iShader

 Created by Treata Norouzi on 2/26/24.
 
 Abstract:
 A collection of AudioVisualization-Shaders, extended to SwiftUI.
*/

import SwiftUI

/// The **AudioVisualizer** Metal shader library.
@dynamicMemberLookup
public enum AudioVisualizerLibrary {
    /**
     Returns a new shader function representing the `[[ stitchable ]]` **MSL**
     function called `name` in the Inferno shader library.
     
     Typically this subscript is used implicitly via the dynamic
     member syntax, for example:
     ```swift
        let fn = AudioVisualizerLibrary.myFunction
     ```
     which creates a reference to the `[[ stitchable ]]` **MSL** function called
     `myFunction()`.
     */
    public static subscript(dynamicMember name: String) -> ShaderFunction {
        ShaderLibrary.bundle(Bundle.module)[dynamicMember: name]
    }
}

/// `BASS` framework is responsible for all the audio playback & analysis
/// which currently is only available for **iOS** & **macOS**.
#if os(iOS) || os(macOS)

public extension View {
    
    // MARK: - Audio Eclipse
    func audioEclipse(fft: [Float], time: Double) -> some View {
        self.colorEffect(
            AudioVisualizerLibrary.audioEclipse(
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
            AudioVisualizerLibrary.shadesOfMusic(
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
            AudioVisualizerLibrary.sineSoundWaves(
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
            AudioVisualizerLibrary.glowingSoundParticles(
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
            AudioVisualizerLibrary.universeWithin(
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
            AudioVisualizerLibrary.galaxyVisuals(
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
            AudioVisualizerLibrary.roundAudioSpecturm(
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
            AudioVisualizerLibrary.wavesRemix(
                .boundingRect,
                .float(time),
                .floatArray(fft)
            )
        )
    }
}

#endif
