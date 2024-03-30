// The Swift Programming Language
// https://docs.swift.org/swift-book

/*
import SwiftUI

/// The **iShader** Metal shader library.
@available(iOS 17, macOS 14, macCatalyst 17, tvOS 17, visionOS 1, *)
@dynamicMemberLookup
public enum iShaderLibrary {
    /**
     Returns a new shader function representing the `[[ stitchable ]]` **MSL**
     function called `name` in the Inferno shader library.
     
     Typically this subscript is used implicitly via the dynamic
     member syntax, for example:
     ```swift
        let fn = iShaderLibrary.myFunction
     ```
     which creates a reference to the `[[ stitchable ]]` **MSL** function called
     `myFunction()`.
     */
    public static subscript(dynamicMember name: String) -> ShaderFunction {
        ShaderLibrary.bundle(Bundle.main)[dynamicMember: name]
    }
}
*/
