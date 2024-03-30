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
    func hypnoticRipples(seconds: Double) -> some View {
        return self.colorEffect(
            ShaderArtLibrary.hypnoticRipples(
                .boundingRect,
                .float(seconds)
            )
        )
    }
    
    // MARK: - Crystal Caustic
    // TODO: Add gestures?
    func crystalCaustic(seconds: Double) -> some View {
        return self.colorEffect(
            ShaderArtLibrary.crystalCaustic(
                .boundingRect,
                .float(seconds)
            )
        )
    }
    
    // MARK: - Beam Droplet
    func beamDroplet(seconds: Double) -> some View {
        return self.colorEffect(
            ShaderArtLibrary.beamDroplet(
                .boundingRect,
                .float(seconds)
            )
        )
    }
    
    // MARK: - Sine Waves
    func sineWaves(seconds: Double, waveCount: Int = 7) -> some View {
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
    func portal(seconds: Double) -> some View {
        return self.colorEffect(
            ShaderArtLibrary.portal(
                .boundingRect,
                .float(seconds)
            )
        )
    }
    
    // MARK: - Neon Rug
    // TODO: Add Gesture? zoom-in/out?
    func neonRug(seconds: Double, neonEffect: Bool = true) -> some View {
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
    func starNest(seconds: Double, translation: CGPoint = .zero) -> some View {
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
    func blueVoid(seconds: Double, touchLocation: CGPoint = .zero) -> some View {
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
    func spiralRiders(seconds: Double) -> some View {
        return self.colorEffect(
            ShaderArtLibrary.spiralRiders(
                .boundingRect,
                .float(seconds)
            )
        )
    }
    
    // MARK: - Black Hole Dawn
    func blackHoleDawn(seconds: Double) -> some View {
        return self.colorEffect(
            ShaderArtLibrary.blackHoleDawn(
                .boundingRect,
                .float(seconds)
            )
        )
    }
    
    // MARK: - Cosmic Blood
    // TODO: Room for optimization?
    func cosmicBlood(seconds: Double) -> some View {
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
    func pulsatingFlesh(seconds: Double, touchLocation: CGPoint = .zero) -> some View {
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
    func clouds(seconds: Double) -> some View {
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
    func baseWarp(seconds: Double, gestureTranslation: CGPoint = .zero) -> some View {
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
    func lensFlare(seconds: Double, gestureTranslation: CGPoint = .zero) -> some View {
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
    func iris(seconds: Double, corneaEdgeHue: Color = .init(red: 0.9, green: 0.6, blue: 0.2)) -> some View {
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
    func retroSun(seconds: Double) -> some View {
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
    func turbulence(seconds: Double, translation: CGPoint = .zero) -> some View {
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
    func lavaBlobs(seconds: Double) -> some View {
        return self.colorEffect(
            ShaderArtLibrary.lavaBlobs(
                .boundingRect,
                .float(seconds)
            )
        )
    }

    // MARK: - TM Gyroids
    func tmGyroids(seconds: Double) -> some View {
        return self.colorEffect(
            ShaderArtLibrary.tmGyroids(
                .boundingRect,
                .float(seconds)
            )
        )
    }
    
    // MARK: - Fire Works
    // TODO: Fireworks on the touched position
    func fireWorks(seconds: Double) -> some View {
        return self.colorEffect(
            ShaderArtLibrary.fireWorks(
                .boundingRect,
                .float(seconds)
            )
        )
    }
    
    // MARK: - Explosion Cloud
    /// worth investing in
    func explosionCloud(seconds: Double) -> some View {
        return self.colorEffect(
            ShaderArtLibrary.explosionCloud(
                .boundingRect,
                .float(seconds)
            )
        )
    }
    
    // MARK: - Mod Fan
    /// Looks great as a WallPaper
    func modFan(seconds: Double) -> some View {
        return self.colorEffect(
            ShaderArtLibrary.modFan(
                .boundingRect,
                .float(seconds)
            )
        )
    }
    
    // MARK: - Star Field
    // TODO: Impelemnt the GPU sound
    func starField(seconds: Double) -> some View {
        return self.colorEffect(
            ShaderArtLibrary.starField(
                .boundingRect,
                .float(seconds)
            )
        )
    }
    
    // MARK: - Singularity
    func singularity(seconds: Double) -> some View {
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
    func glowingMarblingBlack(seconds: Double, translation: CGSize = .init(width: 1, height: 1)) -> some View {
        return self.colorEffect(
            ShaderArtLibrary.glowingMarblingBlack(
                .boundingRect,
                .float(seconds),
                .float2(translation)
            )
        )
    }
    
    
    
}
