/*
 ArtShaders.swift
 iShader

 Created by Treata Norouzi on 3/30/24.
 
 Abstract:
 A collection of Art shaders extended to SwiftUI views for creative visual effects.
*/

import SwiftUI

public extension View {
    
    // MARK: - Hypnotic Ripples
    func hypnoticRipples(seconds: TimeInterval) -> some View {
        return self.colorEffect(
            ShaderArtLibrary.hypnoticRipples(
                .boundingRect,
                .float(seconds)
            )
        )
    }
    
    // MARK: - Crystal Caustic
    // TODO: Add gestures?
    func crystalCaustic(seconds: TimeInterval) -> some View {
        return self.colorEffect(
            ShaderArtLibrary.crystalCaustic(
                .boundingRect,
                .float(seconds)
            )
        )
    }
    
    // MARK: - Beam Droplet
    func beamDroplet(seconds: TimeInterval) -> some View {
        return self.colorEffect(
            ShaderArtLibrary.beamDroplet(
                .boundingRect,
                .float(seconds)
            )
        )
    }
    
    // MARK: - Sine Waves
    func sineWaves(seconds: TimeInterval, waveCount: Int = 7) -> some View {
        return self.colorEffect(
            ShaderArtLibrary.sineWaves(
                .boundingRect,
                .float(seconds),
                .float(Float(waveCount))
            )
        )
    }
    
    // MARK: - Portal
    /// Worth investing in
    func portal(seconds: TimeInterval) -> some View {
        return self.colorEffect(
            ShaderArtLibrary.portal(
                .boundingRect,
                .float(seconds)
            )
        )
    }
    
    // MARK: - Neon Rug
    // TODO: Add Gesture? zoom-in/out?
    func neonRug(seconds: TimeInterval, neonEffect: Bool = true) -> some View {
        return self.colorEffect(
            ShaderArtLibrary.neonRug(
                .boundingRect,
                .float(seconds),
                .float(neonEffect ? 1 : 0)
            )
        )
    }
    
    // MARK: - Star Nest
    /**
     
     > Supports Gesture.
     */
    func starNest(seconds: TimeInterval, translation: CGPoint = .zero) -> some View {
        return self.colorEffect(
            ShaderArtLibrary.starNest(
                .boundingRect,
                .float(seconds),
                .float2(translation)
            )
        )
    }
    
    // MARK: - Blue Void
    /// Also known as `simplicity`
    func blueVoid(seconds: TimeInterval, touchLocation: CGPoint = .zero) -> some View {
        return self.colorEffect(
            ShaderArtLibrary.blueVoid(
                .boundingRect,
                .float(seconds),
                .float2(touchLocation)
            )
        )
    }
    
    // MARK: - Spiral Riders
    /// Extremely resource intensive
    func spiralRiders(seconds: TimeInterval) -> some View {
        return self.colorEffect(
            ShaderArtLibrary.spiralRiders(
                .boundingRect,
                .float(seconds)
            )
        )
    }
    
    // MARK: - Black Hole Dawn
    func blackHoleDawn(seconds: TimeInterval) -> some View {
        return self.colorEffect(
            ShaderArtLibrary.blackHoleDawn(
                .boundingRect,
                .float(seconds)
            )
        )
    }
    
    // MARK: - Cosmic Blood
    // TODO: Room for optimization?
    func cosmicBlood(seconds: TimeInterval) -> some View {
        return self.colorEffect(
            ShaderArtLibrary.cosmicBlood(
                .boundingRect,
                .float(seconds)
            )
        )
    }
    
    // MARK: - Pulsating Flesh
    // FIXME: Looks pixelated
    // The results look a bit noisy that may be caused because of redundant usage of halves instead of floats.
    /**
     
     > Supports Gestures
     */
    func pulsatingFlesh(seconds: TimeInterval, touchLocation: CGPoint = .zero) -> some View {
        self.colorEffect(
            ShaderArtLibrary.pulsatingFlesh(
                .boundingRect,
                .float(seconds),
                .float2(touchLocation)
            )
        )
    }
    
    // MARK: - Clouds
    // TODO: Introduce gestures
    func clouds(seconds: TimeInterval) -> some View {
        return self.colorEffect(
            ShaderArtLibrary.clouds(
                .boundingRect,
                .float(seconds)
            )
        )
    }
    
    // MARK: - Base Warp
    /**
     
     > Supports Gestures
     */
    func baseWarp(seconds: TimeInterval, gestureTranslation: CGPoint = .zero) -> some View {
        return self.colorEffect(
            ShaderArtLibrary.baseWarp(
                .boundingRect,
                .float(seconds),
                .float2(gestureTranslation)
            )
        )
    }
    
    // MARK: - Lens Flare
    /**
     
     > Supports Gestures
     */
    func lensFlare(seconds: TimeInterval, gestureTranslation: CGPoint = .zero) -> some View {
        return self.colorEffect(
            ShaderArtLibrary.lensFlare(
                .boundingRect,
                .float(seconds),
                .float2(gestureTranslation)
            )
        )
    }
    
    // MARK: - Iris
    /// The `BeautiPi`'s logo
    func iris(seconds: TimeInterval, corneaEdgeHue: Color = .init(red: 0.9, green: 0.6, blue: 0.2)) -> some View {
        return self.colorEffect(
            ShaderArtLibrary.iris(
                .boundingRect,
                .float(seconds),
                // yellow towards center
                .color(corneaEdgeHue)
            )
        )
    }
    
    // MARK: - Retro Sun
    func retroSun(seconds: TimeInterval) -> some View {
        return self.colorEffect(
            ShaderArtLibrary.retroSun(
                .boundingRect,
                .float(seconds)
            )
        )
    }
    
    // MARK: - Turbulence
    // TODO: Introduce better gesture effects ...
    /**
     
     > Supports Gesture.
     */
    func turbulence(seconds: TimeInterval, translation: CGPoint = .zero) -> some View {
        return self.colorEffect(
            ShaderArtLibrary.turbulence(
                .boundingRect,
                .float(seconds),
                .float2(translation)
            )
        )
    }
    
    // MARK: - Lava Blobs
    /// Extremely resource intensive
    func lavaBlobs(seconds: TimeInterval) -> some View {
        return self.colorEffect(
            ShaderArtLibrary.lavaBlobs(
                .boundingRect,
                .float(seconds)
            )
        )
    }

    // MARK: - TM Gyroids
    func tmGyroids(seconds: TimeInterval) -> some View {
        return self.colorEffect(
            ShaderArtLibrary.tmGyroids(
                .boundingRect,
                .float(seconds)
            )
        )
    }
    
    // MARK: - Fire Works
    // TODO: Fireworks on the touched position
    func fireWorks(seconds: TimeInterval) -> some View {
        return self.colorEffect(
            ShaderArtLibrary.fireWorks(
                .boundingRect,
                .float(seconds)
            )
        )
    }
    
    // MARK: - Explosion Cloud
    /// worth investing in
    func explosionCloud(seconds: TimeInterval) -> some View {
        return self.colorEffect(
            ShaderArtLibrary.explosionCloud(
                .boundingRect,
                .float(seconds)
            )
        )
    }
    
    // MARK: - Mod Fan
    /// Looks great as a WallPaper
    func modFan(seconds: TimeInterval) -> some View {
        return self.colorEffect(
            ShaderArtLibrary.modFan(
                .boundingRect,
                .float(seconds)
            )
        )
    }
    
    // MARK: - Star Field
    // TODO: Impelemnt the GPU sound
    func starField(seconds: TimeInterval) -> some View {
        return self.colorEffect(
            ShaderArtLibrary.starField(
                .boundingRect,
                .float(seconds)
            )
        )
    }
    
    // MARK: - Singularity
    func singularity(seconds: TimeInterval) -> some View {
        return self.colorEffect(
            ShaderArtLibrary.singularity(
                .boundingRect,
                .float(seconds)
            )
        )
    }
    
    // MARK: - Glowing Marbling Black
    /**
     
     > Supports Gesture.
     */
    func glowingMarblingBlack(seconds: TimeInterval, translation: CGSize = .init(width: 1, height: 1)) -> some View {
        return self.colorEffect(
            ShaderArtLibrary.glowingMarblingBlack(
                .boundingRect,
                .float(seconds),
                .float2(translation)
            )
        )
    }
    
    // MARK: - Electric Field
    // TODO: Introduce Touch compatibility
    func electricField(seconds: TimeInterval) -> some View {
        return self.colorEffect(
            ShaderArtLibrary.electricField(
                .boundingRect,
                .float(seconds)
            )
        )
    }
    
    // MARK: - FBM Lightning
    // Worth investing in.
    func fbmLightning(seconds: TimeInterval) -> some View {
        return self.colorEffect(
            ShaderArtLibrary.fbmLightning(
                .boundingRect,
                .float(seconds)
            )
        )
    }
    
    // MARK: - Wet Neural Network
    // TODO: Potential for Audio Visualization
    // TODO: Better feedback for gestures?
    /**
     
     > Supports Gesture.
     */
    func wetNeuralNetwork(seconds: TimeInterval, touchLocation: CGPoint = .zero) -> some View {
        return self.colorEffect(
            ShaderArtLibrary.wetNeuralNetwork(
                .boundingRect,
                .float(seconds),
                .float2(touchLocation)
            )
        )
    }
    
    // MARK: - Lightning
    // TODO: Do sth with the gestures
    /**
     
     > Supports Gesture.
     > Very similar to `FBMLightning` but not as efficient.
     */
    func lightning01(seconds: TimeInterval, touchLocation: CGPoint = .zero) -> some View {
        return self.colorEffect(
            ShaderArtLibrary.lightning01(
                .boundingRect,
                .float(seconds),
                .float2(touchLocation)
            )
        )
    }
    
}
