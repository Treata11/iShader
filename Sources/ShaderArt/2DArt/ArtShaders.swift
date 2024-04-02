/*
 ArtShaders.swift
 iShader

 Created by Treata Norouzi on 3/30/24.
 
 Abstract:
 A collection of Art shaders extended to SwiftUI views for creative visual effects.
*/

import SwiftUI

// MARK: - Hypnotic Ripples
public struct HypnoticRipples: ShapeStyle, View, Sendable {
    var time: TimeInterval
    
    public init(time: TimeInterval) { self.time = time }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderArtLibrary.hypnoticRipples(
            .boundingRect,
            .float(time)
        )
    }
}

// MARK: - Crystal Caustic
// TODO: Add gestures?
public struct CrystalCaustic: ShapeStyle, View, Sendable {
    var time: TimeInterval
    
    public init(time: TimeInterval) { self.time = time }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderArtLibrary.crystalCaustic(
            .boundingRect,
            .float(time)
        )
    }
}

// MARK: - Beam Droplet
public struct BeamDroplet: ShapeStyle, View, Sendable {
    var time: TimeInterval
    
    public init(time: TimeInterval) { self.time = time }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderArtLibrary.beamDroplet(
            .boundingRect,
            .float(time),
            .float(environment.colorScheme == .dark ? 1 : 0)
        )
    }
}

// MARK: - Sine Waves
public struct SineWaves: ShapeStyle, View, Sendable {
    var relativeColor = Color(red: 0.2, green: 0.2, blue: 0.3)
    var time: TimeInterval
    var waveCount: Int = 7
    
    public init(relativeColor: Color = Color(red: 0.2, green: 0.2, blue: 0.3), time: TimeInterval, waveCount: Int = 7) {
        self.relativeColor = relativeColor
        self.time = time
        self.waveCount = waveCount
    }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderArtLibrary.sineWaves(
            .boundingRect,
            .color(relativeColor),
            .float(time),
            .float(Float(waveCount))
        )
    }
}

// MARK: - Portal
// TODO: Two input colors instead of the hardcoded Blue & Orange
// Worth investing in
public struct Portal: ShapeStyle, View, Sendable {
    var time: TimeInterval
    
    public init(time: TimeInterval) { self.time = time }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderArtLibrary.portal(
            .boundingRect,
            .float(time)
        )
    }
}

// MARK: - Neon Rug
// TODO: Add Gesture? zoom-in/out?
public struct NeonRug: ShapeStyle, View, Sendable {
    var time: TimeInterval
    var neonEffect = true
    
    public init(time: TimeInterval, neonEffect: Bool = true) {
        self.time = time
        self.neonEffect = neonEffect
    }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderArtLibrary.neonRug(
            .boundingRect,
            .float(time),
            .float(neonEffect ? 1 : 0)
        )
    }
}

// MARK: - Star Nest
/**
 
 > Supports Gesture.
 */
public struct StarNest: ShapeStyle, View, Sendable {
    var time: TimeInterval
    /// The touch location
    var location: CGPoint
    
    public init(time: TimeInterval, location: CGPoint) {
        self.time = time
        self.location = location
    }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderArtLibrary.starNest(
            .boundingRect,
            .float(time),
            .float2(location)
        )
    }
}

// MARK: - Blue Void
/**
 
 Also known as `simplicity`
 > Supports Gesture.
 */
public struct BlueVoid: ShapeStyle, View, Sendable {
    var time: TimeInterval
    /// The touch location
    var location: CGPoint
    
    public init(time: TimeInterval, location: CGPoint) {
        self.time = time
        self.location = location
    }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderArtLibrary.blueVoid(
            .boundingRect,
            .float(time),
            .float2(location)
        )
    }
}

// MARK: - Spiral Riders
/// Extremely resource intensive
public struct SpiralRiders: ShapeStyle, View, Sendable {
    var time: TimeInterval
    
    public init(time: TimeInterval) { self.time = time }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderArtLibrary.spiralRiders(
            .boundingRect,
            .float(time)
        )
    }
}

// MARK: - Black Hole Dawn
public struct BlackHoleDawn: ShapeStyle, View, Sendable {
    /// Means that the result color in the shader, might not precisely match the given color.
    var relativeColor = Color(red: 1, green: 0.025, blue: 0)
    var time: TimeInterval
    
    public init(relativeColor: SwiftUI.Color = Color(red: 1, green: 0.025, blue: 0), time: TimeInterval) {
        self.relativeColor = relativeColor
        self.time = time
    }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderArtLibrary.blackHoleDawn(
            .boundingRect,
            .color(relativeColor),
            .float(time)
        )
    }
}

// MARK: - Cosmic Blood
// TODO: Room for optimization?
public struct CosmicBlood: ShapeStyle, View, Sendable {
    var time: TimeInterval
    
    public init(time: TimeInterval) { self.time = time }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderArtLibrary.cosmicBlood(
            .boundingRect,
            .float(time)
        )
    }
}

// MARK: - Pulsating Flesh

// FIXME: Looks pixelated on every platfrom aside from visionOS & tvOS
/**
 
 > Supports Gesture.
 */
public struct PulsatingFlesh: ShapeStyle, View, Sendable {
    var time: TimeInterval
    /// The touch location
    var location: CGPoint
    
    public init(time: TimeInterval, location: CGPoint) {
        self.time = time
        self.location = location
    }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderArtLibrary.pulsatingFlesh(
            .boundingRect,
            .float(time),
            .float2(location)
        )
    }
}

// MARK: - Writhe

// FIXME: Looks pixelated on every platfrom aside from visionOS & tvOS
/**
 
 > Supports Gesture.
 */
public struct Writhe: ShapeStyle, View, Sendable {
    var time: TimeInterval
    /// The touch location
    var location: CGPoint
    
    public init(time: TimeInterval, location: CGPoint) {
        self.time = time
        self.location = location
    }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderArtLibrary.writhe(
            .boundingRect,
            .float(time),
            .float2(location)
        )
    }
}

// MARK: - Clouds
// TODO: Introduce gestures
public struct Clouds: ShapeStyle, View, Sendable {
    var time: TimeInterval
    
    public init(time: TimeInterval) { self.time = time }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderArtLibrary.clouds(
            .boundingRect,
            .float(time)
        )
    }
}

// MARK: - Base Warp
/**
 
 > Supports Gesture.
 */
public struct BaseWarp: ShapeStyle, View, Sendable {
    var time: TimeInterval
    /// The touch location
    var location: CGPoint
    
    public init(time: TimeInterval, location: CGPoint) {
        self.time = time
        self.location = location
    }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderArtLibrary.baseWarp(
            .boundingRect,
            .float(time),
            .float2(location)
        )
    }
}

// MARK: - Lens Flare
/**
 
 > Supports Gesture.
 */
public struct LensFlare: ShapeStyle, View, Sendable {
    var time: TimeInterval
    /// The touch location
    var location: CGPoint
    
    public init(time: TimeInterval, location: CGPoint) {
        self.time = time
        self.location = location
    }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderArtLibrary.lensFlare(
            .boundingRect,
            .float(time),
            .float2(location)
        )
    }
}

// MARK: - Iris
/// The `BeautiPi`'s logo
public struct Iris: ShapeStyle, View, Sendable {
    var irisColor = Color(red: 0, green: 0.3, blue: 0.4)
    var time: TimeInterval
    var corneaEdgeHue: Color = .init(red: 0.9, green: 0.6, blue: 0.2)
    
    public init(
        irisColor: Color = Color(red: 0, green: 0.3, blue: 0.4),
        time: TimeInterval,
        corneaEdgeHue: Color = .init(red: 0.9, green: 0.6, blue: 0.2)
    ) {
        self.irisColor = irisColor
        self.time = time
        self.corneaEdgeHue = corneaEdgeHue
    }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderArtLibrary.iris(
            .boundingRect,
            .color(irisColor),
            .float(time),
            // yellow towards center
            .color(corneaEdgeHue)
        )
    }
}

// MARK: - Retro Sun
public struct RetroSun: ShapeStyle, View, Sendable {
    var time: TimeInterval
    
    public init(time: TimeInterval) { self.time = time }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderArtLibrary.retroSun(
            .boundingRect,
            .float(time)
        )
    }
}

// MARK: - Turbulence
// TODO: Introduce better gesture effects ...
/**
 
 > Supports Gesture.
 */
public struct Turbulence: ShapeStyle, View, Sendable {
    var time: TimeInterval
    /// The touch location
    var location: CGPoint
    
    public init(time: TimeInterval, location: CGPoint) {
        self.time = time
        self.location = location
    }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderArtLibrary.turbulence(
            .boundingRect,
            .float(time),
            .float2(location)
        )
    }
}

// MARK: - Lava Blobs
/// Extremely resource intensive
public struct LavaBlobs: ShapeStyle, View, Sendable {
    var time: TimeInterval
    
    public init(time: TimeInterval) { self.time = time }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderArtLibrary.lavaBlobs(
            .boundingRect,
            .float(time)
        )
    }
}

// MARK: - TM Gyroids
public struct TMGyroids: ShapeStyle, View, Sendable {
    var time: TimeInterval
    
    public init(time: TimeInterval) { self.time = time }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderArtLibrary.tmGyroids(
            .boundingRect,
            .float(time)
        )
    }
}

// MARK: - Fire Works
// TODO: Fireworks on the touched position
public struct FireWorks: ShapeStyle, View, Sendable {
    var time: TimeInterval
    
    public init(time: TimeInterval) { self.time = time }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderArtLibrary.fireWorks(
            .boundingRect,
            .float(time)
        )
    }
}

// MARK: - Explosion Cloud
// worth investing in
public struct ExplosionCloud: ShapeStyle, View, Sendable {
    var time: TimeInterval
    
    public init(time: TimeInterval) { self.time = time }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderArtLibrary.explosionCloud(
            .boundingRect,
            .float(time)
        )
    }
}

// MARK: - Mod Fan
/// Looks great as a WallPaper
public struct ModFan: ShapeStyle, View, Sendable {
    var time: TimeInterval
    
    public init(time: TimeInterval) { self.time = time }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderArtLibrary.modFan(
            .boundingRect,
            .float(time)
        )
    }
}

// MARK: - Star Field
// TODO: Impelement the GPU sound
public struct StarField: ShapeStyle, View, Sendable {
    var time: TimeInterval
    
    public init(time: TimeInterval) { self.time = time }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderArtLibrary.starField(
            .boundingRect,
            .float(time)
        )
    }
}

// MARK: - Singularity
public struct Singularity: ShapeStyle, View, Sendable {
    var time: TimeInterval
    
    public init(time: TimeInterval) { self.time = time }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderArtLibrary.singularity(
            .boundingRect,
            .float(time)
        )
    }
}

// MARK: - Glowing Marbling Black
/**
 
 > Supports Gesture.
 */
public struct GlowingMarblingBlack: ShapeStyle, View, Sendable {
    var time: TimeInterval
    /// The touch location
    var location: CGPoint
    
    public init(time: TimeInterval, location: CGPoint) {
        self.time = time
        self.location = location
    }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderArtLibrary.glowingMarblingBlack(
            .boundingRect,
            .float(time),
            .float2(location)
        )
    }
}

// MARK: - Electric Field
// TODO: Introduce Touch compatibility
public struct ElectricField: ShapeStyle, View, Sendable {
    var time: TimeInterval
    
    public init(time: TimeInterval) { self.time = time }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderArtLibrary.electricField(
            .boundingRect,
            .float(time)
        )
    }
}

// MARK: - FBM Lightning
// Worth investing in.
public struct FBMLightning: ShapeStyle, View, Sendable {
    var lightningColor = Color(red: 0.2, green: 0.3, blue: 0.8)
    var time: TimeInterval
    
    public init(lightningColor: Color = .init(red: 0.2, green: 0.3, blue: 0.8), time: TimeInterval) {
        self.lightningColor = lightningColor
        self.time = time
    }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderArtLibrary.fbmLightning(
            .boundingRect,
            .color(lightningColor),
            .float(time)
        )
    }
}

// MARK: - Wet Neural Network
// TODO: Potential for Audio Visualization
// TODO: Better feedback for gestures?
/**
 
 > Supports Gesture.
 */
public struct WetNeuralNetwork: ShapeStyle, View, Sendable {
    var color = Color(red: 0.25, green: 0.5, blue: 1)
    var time: TimeInterval
    /// The touch location
    var location: CGPoint
    
    public init(color: Color = Color(red: 0.25, green: 0.5, blue: 1),
                time: TimeInterval, location: CGPoint
    ) {
        self.color = color
        self.time = time
        self.location = location
    }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderArtLibrary.wetNeuralNetwork(
            .boundingRect,
            .color(color),
            .float(time),
            .float2(location)
        )
    }
}

// MARK: - Lightning01
// TODO: Do sth with the gestures
/**
 
 > Supports Gesture.
 > Very similar to `FBMLightning` but not as efficient.
 */
public struct Lightning01: ShapeStyle, View, Sendable {
    var lightningColor: Color = .init(red: 1.2, green: 0.2, blue: 0.3)
    var time: TimeInterval
    /// The touch location
    var location: CGPoint
    
    public init(lightningColor: Color = .init(red: 1.2, green: 0.2, blue: 0.3),
                time: TimeInterval, location: CGPoint
    ) {
        self.lightningColor = lightningColor
        self.time = time
        self.location = location
    }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderArtLibrary.lightning01(
            .boundingRect,
            .color(lightningColor),
            .float(time),
            .float2(location)
        )
    }
}
