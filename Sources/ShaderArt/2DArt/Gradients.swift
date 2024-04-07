/*
 Gradients.swift
 iShader

 Created by Treata Norouzi on 2/29/24.
 
 Abstract:
 A collection of Art shaders that could be considered as Gradient effects
*/

import SwiftUI

// MARK: - Rotating Gradient

public struct RotatingGradient: ShapeStyle, View, Sendable {
    var time: TimeInterval
    var startColor: Color
    var endColor: Color
    
    public init(time: TimeInterval, startColor: Color, endColor: Color) {
        self.time = time
        self.startColor = startColor
        self.endColor = endColor
    }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderArtLibrary.rotatingGradient(
            .boundingRect,
            .float(time),
            .color(startColor),
            .color(endColor)
        )
    }
}

// MARK: - Chroma Gradients

public struct ChromaGradients: ShapeStyle, View, Sendable {
    var time: TimeInterval
    
    public init(time: TimeInterval) { self.time = time }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderArtLibrary.chromaGradients(
            .boundingRect,
            .float(time)
        )
    }
}

// MARK: - Fluid Gradient

// TODO: Instead of the hard-coded fluids, modify the shader to accept an array of color and create spheres for them
public struct FluidGradient: ShapeStyle, View, Sendable {
    var time: TimeInterval
    
    public init(time: TimeInterval) { self.time = time }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderArtLibrary.fluidGradient(
            .boundingRect,
            .float(time)
        )
    }
}

// MARK: - Gradientify

public struct Gradientify: ShapeStyle, View, Sendable {
    var time: TimeInterval
    
    public init(time: TimeInterval) { self.time = time }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderArtLibrary.gradientify(
            .boundingRect,
            .float(time)
        )
    }
}

// MARK: - Gradient Flow

// FIXME: Limited to an array of 4 colors.
public struct GradientFlow: ShapeStyle, View, Sendable {
    var colors: [Color] = [.orange, .cyan, .pink, .indigo]
    var time: TimeInterval
    
    public init(colors: [Color] = [.orange, .cyan, .pink, .indigo], time: TimeInterval) {
        self.colors = colors
        self.time = time
    }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderArtLibrary.gradientFlow(
            .boundingRect,
            .float(time),
            .colorArray(colors)
        )
    }
}

// MARK: - Rainbow Sherbet

/**
 
 > Supports Gesture.
 */
public struct RainbowSherbet: ShapeStyle, View, Sendable {
    var time: TimeInterval
    /// The touch location
    var location: CGPoint
    
    public init(time: TimeInterval, location: CGPoint) {
        self.time = time
        self.location = location
    }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderArtLibrary.rainbowSherbet(
            .boundingRect,
            .float(time),
            .float2(location)
        )
    }
}

// MARK: - Crumpled Wave

public struct CrumpledWave: ShapeStyle, View, Sendable {
    var time: TimeInterval

    public init(time: TimeInterval) { self.time = time }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderArtLibrary.crumpledWave(
            .boundingRect,
            .float(time)
        )
    }
}

// MARK: - Glossy Gradients

/**
 
 > Supports Gesture.
 */
public struct GlossyGradients: ShapeStyle, View, Sendable {
    var time: TimeInterval
    /// The touch location
    var location: CGPoint
    
    public init(time: TimeInterval, location: CGPoint) {
        self.time = time
        self.location = location
    }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderArtLibrary.glossyGradients(
            .boundingRect,
            .float(time),
            .float2(location)
        )
    }
}

// MARK: - Color Wind

/**
 
 > Supports Gesture.
 */
public struct ColorWind: ShapeStyle, View, Sendable {
    var time: TimeInterval
    /// The touch location
    var location: CGPoint
    
    public init(time: TimeInterval, location: CGPoint) {
        self.time = time
        self.location = location
    }
    
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        ShaderArtLibrary.colorWind(
            .boundingRect,
            .float(time),
            .float2(location)
        )
    }
}
