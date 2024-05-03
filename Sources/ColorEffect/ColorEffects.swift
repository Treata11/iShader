/*
 ColorEffects.swift
 iShader

 Created by Treata Norouzi on 3/28/24.
 
 Abstract:
 A collection of ColorEffect-Shaders as view-modifier methods.
*/

import SwiftUI

public extension View {
    
    // MARK: - Luminence
    
    func luminence(isEnabled: Bool = true) -> some View {
        self.colorEffect(
            ColorEffectLibrary.luminence(),
            isEnabled: isEnabled)
    }
    
    // MARK: - Εxposure
    
    func exposure(value: Float, isEnabled: Bool = true) -> some View {
        self.colorEffect(
            ColorEffectLibrary.exposure(.float(value)),
            isEnabled: isEnabled)
    }
    
    // MARK: - Gamma
    
    func gamma(value: Float, isEnabled: Bool = true) -> some View {
        self.colorEffect(
            ColorEffectLibrary.gamma(.float(value)),
            isEnabled: isEnabled)
    }
    
    // MARK: - Vibrance
    
    func vibrance(value: Float, isEnabled: Bool = true) -> some View {
        self.colorEffect(
            ColorEffectLibrary.vibrance(.float(value)),
            isEnabled: isEnabled
        )
    }
    
    // MARK: - Vignette
    
    // FIXME: Very cheap for negative vignette
    func vignette(intensity: Float = 15, value: Float, isEnabled: Bool = true) -> some View {
        self.colorEffect(
            ColorEffectLibrary.vignette(
                .boundingRect,
                .float(intensity),
                .float(value)
            ),
            isEnabled: isEnabled
        )
    }
    
    // MARK: - Night Vision
    
    // Worth investing in
    func nightVision(time: TimeInterval, isEnabled: Bool = true) -> some View {
        self.colorEffect(
            ColorEffectLibrary.nightVision(
                .boundingRect,
                .float(time)
            ),
            isEnabled: isEnabled
        )
    }
    
    // MARK: - Infrared
    
    /**
     Simulates an infrared camera by coloring brighter objects red and darker objects blue.

     **Parameters:**

     - None.
     */
    func infrared(isEnabled: Bool = true) -> some View {
        return self.colorEffect(
            ColorEffectLibrary.infrared(),
            isEnabled: isEnabled
        )
    }
    
    // MARK: - CRT
    
    func crt(xPass: Bool = true, yPass: Bool = true) -> some View {
        return self.colorEffect(
            ColorEffectLibrary.crt(
                .boundingRect,
                .float(xPass ? 1 : 0),
                .float(yPass ? 1 : 0)
            )
        )
    }
    
    // MARK: - Lightbulb Screen
    
    func lightbulbScreen(bulbCount: Int = 32) -> some View {
        return self.colorEffect(
            ColorEffectLibrary.lightbulbScreen(
                .boundingRect,
                .float(Float(bulbCount))
            )
        )
    }
    
    // MARK: - Film Grain
    
    func filmGrain(time: TimeInterval, strength: Float = 32, fineGrain: Bool = true, isEnabled: Bool = true) -> some View {
        return self.colorEffect(
            ColorEffectLibrary.filmGrain(
                .boundingRect,
                .float(time),
                .float(strength),
                .float(fineGrain ? 1 : 0)
            ),
            isEnabled: isEnabled
        )
    }
    
    // MARK: - Tileable Water Caustic
    
    func tileableWaterCaustic(time: TimeInterval, showTiling: Bool = false, isEnabled: Bool = true) -> some View {
        return self.colorEffect(
            ColorEffectLibrary.tileableWaterCaustic(
                .boundingRect,
                .float(time),
                .float(showTiling ? 1 : 0)
            ),
            isEnabled: isEnabled
        )
    }
}
