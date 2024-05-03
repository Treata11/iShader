/*
 BundleExtensions.swift
 iShader

 Created by Treata Norouzi on 4/30/24.
*/

import SwiftUI

public extension Bundle {
    static let layerEffect: Bundle = .module
}

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
        ShaderLibrary.bundle(.layerEffect)[dynamicMember: name]
    }
}
