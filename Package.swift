// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "iShader",
    
    platforms: [.iOS(.v17), .macOS(.v14), .visionOS(.v1)],
    
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "iShader",
            type: .static,
            targets: ["iShader"]
        ),
        .library(
            name: "AudioVisualizer",
            targets: ["AudioVisualizer"]
        ),
        .library(
            name: "ColorEffect",
            targets: ["ColorEffect"]
        )
    ],
    
    dependencies: [
        .package(url: "https://github.com/Treata11/CBass", branch: "main")
    ],
    
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "iShader",
            dependencies: [
                .target(name: "AudioVisualizer"),
                .target(name: "ColorEffect")
            ]
        ),
        .target(
            name: "AudioVisualizer",
            dependencies: ["CBass"]
        ),
        .target(
            name: "ColorEffect",
            dependencies: []
        ),
        
        // test targets
        .testTarget(
            name: "iShaderTests",
            dependencies: ["iShader"]),
    ],
    
    swiftLanguageVersions: [.v5]
)
