/*
 AudioVisualizers.swift
 iShader

 Created by Treata Norouzi on 2/26/24.
 
 Abstract:
 A collection of AudioVisualization-Shaders as ShapeStyles.
*/

import SwiftUI

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
            .float2(location),
            .floatArray(fft)
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
            .color(backgroundColor),
            .floatArray(fft),
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
