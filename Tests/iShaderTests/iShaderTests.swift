import XCTest
@testable import iShader
@testable import ColorEffect

final class iShaderTests: XCTestCase {
    func testExample() throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
    }
    
    /// Always fails ...
    func testBundleSourceString() throws {
        let fileName = "Shaders/CRT"
        let bundle = Bundle.colorEffect
        bundle.load()
        
        if bundle.isLoaded {
            if let sourceURL = bundle.url(forResource: fileName, withExtension: "metal") {
                let sourceString = try? String(contentsOf: sourceURL, encoding: .utf8)
                print("Source String: \n\(sourceString!)")
            } else {
                XCTFail("testBundleSourceString FAILED ❌")
            }
        } else {
            XCTFail("Failed to load ColorEffect module ❌")
        }
    }

    func testColorEffectBundle() throws {
        Bundle.colorEffect.load()
        
        print("""
            Color-Effect-Module bundleIdentifier:
                \(Bundle.colorEffect.bundleIdentifier ?? "NA")
            Color-Effect-Module bundleURL:
                \(Bundle.colorEffect.bundleURL)
            Color-Effect-Module bundlePath:
                \(Bundle.colorEffect.bundlePath)
            
            """)
    }
}
