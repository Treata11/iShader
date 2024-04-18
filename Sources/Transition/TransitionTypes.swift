/*
 TransitionTypes.swift
 MetalShaders

 Created by Treata Norouzi on 4/18/24.
 
 Abstract:
 Transitions could be ColorEffect, DistortionEffect and LayerEffect.
 So there's a simple ViewModifier template created for each case in this file.
*/

import SwiftUI

// MARK: - ColorEffect

internal struct ColorEffectTransition: ViewModifier {
    /// The name of the shader function we're rendering.
    var name: String

    /// Indicates whether the transition has started or finished.
    var isFinished = false

    func body(content: Content) -> some View {
        content
            .visualEffect { content, proxy in
                content
                    .colorEffect(
                        TransitionLibrary[dynamicMember: name](
                            .float2(proxy.size),
                            .float(isFinished ? 1 : 0))
                    )
            }
    }
}

// MARK: - Layer Effect

/// A Metal-powered layer effect transition that needs to know the
/// view's size.
internal struct LayerEffectTransition: ViewModifier {
    /// The name of the shader function we're rendering.
    var name: String

    /// Indicates whether the transition has started or finished.
    var isFinished = false

    func body(content: Content) -> some View {
        content
            .visualEffect { content, proxy in
                content
                    .layerEffect(
                        TransitionLibrary[dynamicMember: name](
                            .float2(proxy.size),
                            .float(isFinished ? 1 : 0)
                        ), maxSampleOffset: .zero)
            }
    }
}

// MARK: - Distortion Effect

/// A Metal-powered distortion effect transition that needs to know
/// the view's size.
internal struct DistortionEffectTransition: ViewModifier {
    /// The name of the shader function we're rendering.
    var name: String

    /// Indicates whether the transition has started or finished.
    var isFinished = false

    func body(content: Content) -> some View {
        content
            .visualEffect { content, proxy in
                content
                    .distortionEffect(
                        TransitionLibrary[dynamicMember: name](
                            .float2(proxy.size),
                            .float(isFinished ? 1 : 0)
                        ), maxSampleOffset: .zero)
            }
    }
}
