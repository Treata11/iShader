import XCTest
import Metal
@testable import iShader
@testable import ColorEffect

final class iShaderTests: XCTestCase {
    func testExample() throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
    }

    /// Always succeeds!
    ///
    /// Discussed at: https://forums.swift.org/t/difficulty-accessing-resources-in-a-packages-bundle/71598/5
    /// Solved by [Christophe Bronner](https://github.com/Lancelotbronner)
    func testBundleSourceString() throws {
        let url = Bundle.colorEffect.url(forResource: "default", withExtension: "metallib")
        XCTAssertNotNil(url, "Failed to load ColorEffect metal library")
        if let url {
            print(url)
        }
    }
    
    /// WIP
    func testMakeDefaultLibrary() throws {
        // Create a Metal device
        let device = MTLCreateSystemDefaultDevice()!
        let colorEffectLibrary = try device.makeDefaultLibrary(bundle: Bundle.colorEffect)
//        let functionNames = colorEffectLibrary.functionNames
    }
}
