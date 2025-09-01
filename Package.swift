// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MRReachability",
    platforms: [
        .iOS(.v12),
        .tvOS(.v12)
    ],
    products: [
        .library(
            name: "MRReachability",
            targets: ["MRReachability"]
        )
    ],
    targets: [
        .target(
            name: "MRReachability",
            dependencies: [],
            path: "Sources/MRReachability"
        ),
        .testTarget(
            name: "MRReachabilityTests",
            dependencies: ["MRReachability"],
            path: "Tests/MRReachabilityTests"
        )
    ]
)
