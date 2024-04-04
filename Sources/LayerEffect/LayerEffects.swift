/*
 LayerEffects.swift

 Created by Treata Norouzi on 3/30/24.
 
 Abstract:
 A collection of layerEffects extended to SwiftUI Views
*/

import SwiftUI

/// The **LayerEffect** Metal shader library.
@dynamicMemberLookup
public enum LayerEffectLibrary {
    /**
     Returns a new shader function representing the `[[ stitchable ]]` **MSL**
     function called `name` in the Inferno shader library.
     
     Typically this subscript is used implicitly via the dynamic
     member syntax, for example:
     ```swift
        let fn = LayerEffectLibrary.myFunction
     ```
     which creates a reference to the `[[ stitchable ]]` **MSL** function called
     `myFunction()`.
     */
    public static subscript(dynamicMember name: String) -> ShaderFunction {
        ShaderLibrary.bundle(Bundle.module)[dynamicMember: name]
    }
}



public extension VisualEffect {
    
    // MARK: - Bubble
    
    // TODO: An array of location as input instead of a single bubble
    /**
     A `layerEffect()` shader that creates a simple soap bubble effect over a precise location.
     
     **Parameters:**
     
     - `uiSize`: The size of the whole image, in user-space.
     - `uiPosition`: The location, where the bubble should be centered, in user-space.
     - `uiRadius`: How large the bubble area should be, in user-space.
     */
    func bubble(
        size: CGSize,
        location: CGPoint,
        radius: Float = 50,
        maxSampleOffset: CGSize = .zero
    ) -> some VisualEffect {
        return layerEffect(
            LayerEffectLibrary.bubble(
                .float2(size),
                .float2(location),
                .float(radius)
            ),
            maxSampleOffset: maxSampleOffset
        )
    }
    
    // MARK: - Warping Loupe
    
    /**
     A `layerEffect()` shader that creates a circular zoom effect over a precise location, with variable zoom around the touch area to create a glass orb-like effect.

     **Parameters:**

     - `size`: The size of the whole image, in user-space.
     - `touch`: The location the user is touching, where the zoom should be centered.
     - `maxDistance`: How big to make the zoomed area. Try starting with 0.05.
     - `zoomFactor`: How much to zoom the contents of the loupe.
     */
    func warpingLoupe(
        size: CGSize,
        location: CGPoint,
        maxDistance: Float = 0.05,
        zoomFactor: Float = 2,
        maxSampleOffset: CGSize = .zero
    ) -> some VisualEffect {
        return layerEffect(
            LayerEffectLibrary.warpingLoupe(
                .float2(size),
                .float2(location),
                .float(maxDistance),
                .float(zoomFactor)
            ),
            maxSampleOffset: maxSampleOffset
        )
    }
}

// MARK: - View Extensions -

public extension View {
    
    // MARK: - Color Planes
    
    /**
     
     > Supports Gesture.
     */
    func colorPlanes(translation: CGSize = .zero) -> some View {
        return self.layerEffect(
            LayerEffectLibrary.colorPlanes(
                .float2(translation)
            ),
            maxSampleOffset: .zero
        )
    }
    
    // MARK: - Emboss
    
    /**
     A `layerEffect()` shader that creates an embossing effect by adding brightness from pixels in one direction, and subtracting brightness from pixels in the other direction.

     **Parameters:**

     - `strength`: How far we should we read pixels to create the effect.
     */
    func emboss(embossAmount: Float, maxSampleOffset: CGSize = .zero) -> some View {
        return self.layerEffect(
            LayerEffectLibrary.emboss(
                .boundingRect,
                .float(embossAmount)
            ),
            maxSampleOffset: maxSampleOffset
        )
    }
    
    // MARK: - VHS

    // !!!: WIP, There are still some vertically descending noises missing
    /// WIP
    func vhs(time: TimeInterval) -> some View {
        return self.layerEffect(
            LayerEffectLibrary.vhs(
                .boundingRect,
                .float(time)
            ),
            maxSampleOffset: .zero
        )
    }
    
    // MARK: - Sobel
    
    func sobel(step: Float = 1) -> some View {
        return self.layerEffect(
            LayerEffectLibrary.sobel(
                .float(step)
            ),
            maxSampleOffset: .zero
        )
    }
    
    // MARK: - Soft Threshold
    
    func softThreshold() -> some View {
        return self.layerEffect(
            LayerEffectLibrary.softThreshold(),
            maxSampleOffset: .zero
        )
    }
    
    // MARK: - Sine Wave

    // TODO: Optimize
    func sineWave(time: TimeInterval, intensity: Float = 10) -> some View {
        return self.layerEffect(
            LayerEffectLibrary.sineWave(
                .boundingRect,
                .float(time),
                .float(intensity)
            ),
            maxSampleOffset: .zero
        )
    }
}


