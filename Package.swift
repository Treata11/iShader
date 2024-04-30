// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "iShader",
    
    platforms: [.iOS(.v17), .macOS(.v14), .macCatalyst(.v15), .tvOS(.v15), .visionOS(.v1)],
    
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "iShader",
//            type: .static,
            targets: ["iShader"]
        ),
        .library(
            name: "AudioVisualizer",
            targets: ["AudioVisualizer"]
        ),
        .library(
            name: "ColorEffect",
            targets: ["ColorEffect"]
        ),
        .library(
            name: "DistortionEffect",
            targets: ["DistortionEffect"]
        ),
        .library(
            name: "LayerEffect",
            targets: ["LayerEffect"]
        ),
        .library(
            name: "ShaderArt",
            targets: ["ShaderArt"]
        ),
        .library(
            name: "Transition",
            targets: ["Transition"]
        )
    ],

    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "iShader",
            dependencies: [
                .target(name: "AudioVisualizer"),
                .target(name: "ColorEffect"),
                .target(name: "DistortionEffect"),
                .target(name: "LayerEffect"),
                .target(name: "ShaderArt"),
                .target(name: "Transition")
            ]
        ),
        .target(
            name: "AudioVisualizer",
            resources: [.process("Shaders")]
        ),
        .target(
            name: "ColorEffect",
            resources: [.process("Shaders")]
        ),
        .target(
            name: "DistortionEffect",
            resources: [.process("Shaders")]
        ),
        .target(
            name: "LayerEffect",
            resources: [.process("Shaders")]
        ),
        .target(
            name: "ShaderArt",
            resources: [.process("2DArt/Shaders")]
        ),
        .target(
            name: "Transition",
            resources: [.process("Shaders")]
        ),
        
        // test targets
        .testTarget(
            name: "iShaderTests",
            dependencies: [
                .target(name: "iShader")
            ]
        )
    ],
    
    swiftLanguageVersions: [.v5]
)
