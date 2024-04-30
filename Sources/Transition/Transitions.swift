/*
 Transitions.swift
 iShader

 Created by Treata Norouzi on 4/17/24.
 
 Abstract:
 A collection of Transition-Shaders extended to SwiftUI's AnyTransition
*/

import SwiftUI

// MARK: - Circle

private struct CircleTransition: ViewModifier {
    /// How big to make the circles.
    var size = 20.0

    /// Indicates whether the transition has started or finished.
    var isFinished = false

    func body(content: Content) -> some View {
        content
            .colorEffect(
                TransitionLibrary.circleTransition(
                    .float(isFinished ? 1 : 0),
                    .float(size)
                )
            )
    }
}

extension AnyTransition {
    /**
     A transition that makes a variety of circles simultaneously zoom up
     across the screen.
     - Parameters:
     - Parameter size: The size of the circles.
     */
    public static func circles(size: Double = 20) -> AnyTransition {
        .asymmetric(
            insertion: .modifier(
                active: CircleTransition(size: size, isFinished: false),
                identity: CircleTransition(size: size, isFinished: true)
            ),
            removal: .scale(scale: 1 + Double.ulpOfOne)
        )
    }
}

// MARK: - Swirl

private struct SwirlTransition: ViewModifier {
    /// How large the swirl should be relative to the view it's transitioning.
    var radius = 0.5

    /// Indicates whether the transition has started or finished.
    var isFinished = false

    func body(content: Content) -> some View {
        content
            .visualEffect { content, proxy in
                content
                    .layerEffect(
                        TransitionLibrary.swirl(
                            .float2(proxy.size),
                            .float(isFinished ? 1 : 0),
                            .float(radius)
                        ), maxSampleOffset: .zero)
            }
    }
}

extension AnyTransition {
    /**
     A transition that increasingly twists the contents of the incoming and outgoing
     views, then untwists them to complete the transition. As this happens the two
     views fade to move smoothly from one to the other.
     - Parameters:
     - Parameter radius: How much of the view to swirl, in the range 0 to 1. Start with 0.5 and experiment.
     */
    public static func swirl(radius: Double = 0.5) -> AnyTransition {
        .asymmetric(
            insertion: .modifier(
                // FIXME: Duplicate code
                active: SwirlTransition(radius: radius, isFinished: true),
                identity: SwirlTransition(radius: radius, isFinished: false)
            ),
            removal: .modifier(
                active: SwirlTransition(radius: radius, isFinished: true),
                identity: SwirlTransition(radius: radius, isFinished: false)
            )
        )
    }
}

// MARK: - Genie

extension AnyTransition {
    /// A transition that causes the incoming and outgoing views to become
    /// sucked in and ouf of the top right corner.
    public static func genie() -> AnyTransition {
        .asymmetric(
            // FIXME: Duplicate code
            insertion: .modifier(
                active: DistortionEffectTransition(name: "genieTranstion", isFinished: true),
                identity: DistortionEffectTransition(name: "genieTranstion", isFinished: false)
            ),
            removal: .modifier(
                active: DistortionEffectTransition(name: "genieTranstion", isFinished: true),
                identity: DistortionEffectTransition(name: "genieTranstion", isFinished: false)
            )
        )
    }
}

// MARK: - Wind

private struct WindTransition: ViewModifier {
    /// How long the streaks should be, relative to the view's width.
    var size = 0.2

    /// Indicates whether the transition has started or finished.
    var isFinished = false

    func body(content: Content) -> some View {
        content
            .visualEffect { content, proxy in
                content
                    .colorEffect(
                        TransitionLibrary.windTransition(
                            .float2(proxy.size),
                            .float(isFinished ? 1 : 0),
                            .float(size))
                    )
            }
    }
}

extension AnyTransition {
    /**
     A transition that makes it look the pixels of one image are being blown
     away horizontally.
     - Parameters:
     - Parameter size: How big the wind streaks should be, relative to the view's width.
     */
    public static func wind(size: Double = 0.2) -> AnyTransition {
        .asymmetric(
            insertion: .modifier(
                active: WindTransition(size: size, isFinished: true),
                identity: WindTransition(size: size, isFinished: false)
            ),
            removal: .scale(scale: 1 + Double.ulpOfOne)
        )
    }
}

// MARK: - Radial

extension AnyTransition {
    /// A transition that creates an old-school radial wipe, starting from straight up.
    public static let radial: AnyTransition = .asymmetric(
        insertion: .modifier(
            active: ColorEffectTransition(name: "radialTransition", isFinished: true),
            identity: ColorEffectTransition(name: "radialTransition", isFinished: false)
        ),
        removal: .scale(scale: 1 + Double.ulpOfOne)
    )
}

// MARK: - Crosswarp

private struct CrosswarpTransition: ViewModifier {
    /// A `right-to-left` or a `left-to-right` transition
    var rightToLeft = true

    /// Indicates whether the transition has started or finished.
    var isFinished = false

    func body(content: Content) -> some View {
        content
            .visualEffect { content, proxy in
                content
                    .layerEffect(
                        TransitionLibrary.crosswarp(
                            .float2(proxy.size),
                            .float(isFinished ? 1 : 0),
                            .float(rightToLeft ? 1 : 0)
                        ), maxSampleOffset: .zero)
            }
    }
}

extension AnyTransition {
    public static func crosswarp(rightToLeft: Bool = true) -> AnyTransition {
        .asymmetric(
            insertion: .modifier(
                active: CrosswarpTransition(rightToLeft: rightToLeft, isFinished: true),
                identity: CrosswarpTransition(rightToLeft: rightToLeft, isFinished: false)
            ),
            removal: .modifier(
                active: CrosswarpTransition(rightToLeft: !rightToLeft, isFinished: true),
                identity: CrosswarpTransition(rightToLeft: !rightToLeft, isFinished: false)
            )
        )
    }
}
 
// MARK: - Dreamy

// FIXME: Isn't it a DistortionEffect similar to wave?
extension AnyTransition {
    public static let dreamy: Self = .asymmetric(
        insertion: .modifier(
            active: LayerEffectTransition(name: "dreamy", isFinished: true),
            identity: LayerEffectTransition(name: "dreamy", isFinished: false)
        ),
        removal: .scale(scale: 1 + Double.ulpOfOne)
    )
}

// MARK: - Window Blinds

private struct WindowBlindsTransition: ViewModifier {
    /// Relative count of the blinds
    var count = 100

    /// Indicates whether the transition has started or finished.
    var isFinished = false

    func body(content: Content) -> some View {
        content
            .visualEffect { content, proxy in
                content
                    .colorEffect(
                        TransitionLibrary.windowBlinds(
                            .float2(proxy.size),
                            .float(isFinished ? 1 : 0),
                            .float(Float(count)))
                    )
            }
    }
}

extension AnyTransition {
    public static func windowBlinds(count: Int = 100) -> Self {
        .asymmetric(
            insertion: .modifier(
                active: WindowBlindsTransition(count: count, isFinished: true),
                identity: WindowBlindsTransition(count: count, isFinished: false)
            ),
            removal: .scale(scale: 1 + Double.ulpOfOne)
        )
    }
}

// MARK: - Morph

private struct MorphTransition: ViewModifier {
    var strength: Float = 0.1

    /// Indicates whether the transition has started or finished.
    var isFinished = false

    func body(content: Content) -> some View {
        content
            .visualEffect { content, proxy in
                content
                    .layerEffect(
                        TransitionLibrary.morph(
                            .float2(proxy.size),
                            .float(isFinished ? 1 : 0),
                            .float(strength)),
                        maxSampleOffset: .zero
                    )
            }
    }
}

// FIXME: Isn't it a DistortionEffect
extension AnyTransition {
    public static func morph(strength: Float = 0.1) -> Self {
        // FIXME: Duplicate code
        .asymmetric(
            insertion: .modifier(
                active: MorphTransition(strength: strength, isFinished: true),
                identity: MorphTransition(strength: strength, isFinished: false)
            ),
            removal: .modifier(
                active: MorphTransition(strength: strength, isFinished: true),
                identity: MorphTransition(strength: strength, isFinished: false)
            )
        )
    }
}
