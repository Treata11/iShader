/*
 File.swift
 iShader

 Created by Treata Norouzi on 3/28/24.
 
 Abstract:
 
*/

import SwiftUI

/// The **DistortionEffect** Metal shader library.
@dynamicMemberLookup
public enum ColorEffectLibrary {
    /**
     Returns a new shader function representing the `[[ stitchable ]]` **MSL**
     function called `name` in the Inferno shader library.
     
     Typically this subscript is used implicitly via the dynamic
     member syntax, for example:
     ```swift
        let fn = ColorEffectLibrary.myFunction
     ```
     which creates a reference to the `[[ stitchable ]]` **MSL** function called
     `myFunction()`.
     */
    public static subscript(dynamicMember name: String) -> ShaderFunction {
        ShaderLibrary.bundle(Bundle.module)[dynamicMember: name]
    }
}



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
            ShaderLibrary.infrared(),
            isEnabled: isEnabled
        )
    }
}
