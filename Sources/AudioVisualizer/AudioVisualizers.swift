/*
 AudioVisualizers.swift
 iShader

 Created by Treata Norouzi on 2/26/24.
 
 Abstract:
 A collection of AudioVisualization-Shaders as ShapeStyles.
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

// MARK: - Audio Eclipse

public struct AudioEclipse: ShapeStyle, View, Sendable {
    var time: TimeInterval
    var fft: [Float]
    
    public init(time: TimeInterval, fft: [Float]) {
        self.time = time
        self.fft = fft
    }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        AudioVisualizerLibrary.audioEclipse(
            .boundingRect,
            .float(time),
            .floatArray(fft)
        )
    }
}

// MARK: - Shades of Music

// TODO: Add support for gestures in the shader code.
// looks better in landScape
public struct ShadesOfMusic: ShapeStyle, View, Sendable {
    var time: TimeInterval
    var fft: [Float]
    
    public init(time: TimeInterval, fft: [Float]) {
        self.time = time
        self.fft = fft
    }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        AudioVisualizerLibrary.shadesOfMusic(
            .boundingRect,
            .float(time),
            .floatArray(fft)
        )
    }
}

// MARK: - Sine Sound Waves

public struct SineSoundWaves: ShapeStyle, View, Sendable {
    var time: TimeInterval
    var fft: [Float]
    var waveCount: Int = 7
    
    public init(time: TimeInterval, fft: [Float]) {
        self.time = time
        self.fft = fft
    }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        AudioVisualizerLibrary.sineSoundWaves(
            .boundingRect,
            .float(time),
            .floatArray(fft),
            .float(Float(waveCount))
        )
    }
}

// MARK: - Glowing Sound Particles

public struct GlowingSoundParticles: ShapeStyle, View, Sendable {
    var time: TimeInterval
    var fft: [Float]
    
    public init(time: TimeInterval, fft: [Float]) {
        self.time = time
        self.fft = fft
    }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        AudioVisualizerLibrary.glowingSoundParticles(
            .boundingRect,
            .float(time),
            .floatArray(fft)
        )
    }
}

// MARK: - Universe Within

/**
 
 > Supports Gesture.
 */
public struct UniverseWithin: ShapeStyle, View, Sendable {
    var time: TimeInterval
    var fft: [Float]
    /// The touch location
    var location: CGPoint

    public init(time: TimeInterval, fft: [Float], location: CGPoint) {
        self.time = time
        self.fft = fft
        self.location = location
    }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        AudioVisualizerLibrary.universeWithin(
            .boundingRect,
            .float(time),
            .floatArray(fft),
            .float2(location)
        )
    }
}

// MARK: - Galaxy Visuals

// FIXME: There's a negative vignette applied ...
public struct GalaxyVisuals: ShapeStyle, View, Sendable {
    var time: TimeInterval
    var fft: [Float]
    
    public init(time: TimeInterval, fft: [Float]) {
        self.time = time
        self.fft = fft
    }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        AudioVisualizerLibrary.galaxyVisuals(
            .boundingRect,
            .float(time),
            .floatArray(fft)
        )
    }
}

// MARK: - Round Audio Specturm

// TODO: Optimize
// TODO: Colorize the Capsules
public struct RoundAudioSpecturm: ShapeStyle, View, Sendable {
    var fft: [Float]
    var backgroundColor: Color = .black
    var rayCount: Int = 78
    
    public init(fft: [Float], backgroundColor: Color = .black, rayCount: Int = 78) {
        self.fft = fft
        self.backgroundColor = backgroundColor
        self.rayCount = rayCount
    }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        AudioVisualizerLibrary.roundAudioSpecturm(
            .boundingRect,
            .floatArray(fft),
            .color(backgroundColor),
            .float(Float(rayCount))
        )
    }
}

// MARK: - Waves Remix

// FIXME: Waves are too noisy
/// Looks way better in `landScape`
public struct WavesRemix: ShapeStyle, View, Sendable {
    var time: TimeInterval
    var fft: [Float]
    
    public init(time: TimeInterval, fft: [Float]) {
        self.time = time
        self.fft = fft
    }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        AudioVisualizerLibrary.wavesRemix(
            .boundingRect,
            .float(time),
            .floatArray(fft)
        )
    }
}

#endif
