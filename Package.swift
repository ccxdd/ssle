// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SSLE",
    platforms: [.macOS(.v10_12),
                .iOS(.v10),
                .tvOS(.v10),
                .watchOS(.v3)],
    products: [.library(name: "SSLE",
                        targets: ["SSLE"])],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.2.0")),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMinor(from: "1.3.1")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SSLE",
            dependencies: ["Alamofire", "CryptoSwift"],
            path: "Sources",
            exclude: [
                "vendor/GCDTimer.swift",
                "vendor/MWHttpClient.swift",
            ]
            ),
//        .testTarget(
//            name: "SSLETests",
//            dependencies: ["SSLE"],
//            path: "Tests"),
    ],
    swiftLanguageVersions: [.v5]
)

/*
let package = Package(name: "Alamofire",
                      platforms: [.macOS(.v10_12),
                                  .iOS(.v10),
                                  .tvOS(.v10),
                                  .watchOS(.v3)],
                      products: [.library(name: "Alamofire",
                                          targets: ["Alamofire"])],
                      targets: [.target(name: "Alamofire",
                                        path: "Source",
                                        linkerSettings: [.linkedFramework("CFNetwork",
                                                                          .when(platforms: [.iOS,
                                                                                            .macOS,
                                                                                            .tvOS,
                                                                                            .watchOS]))]),
                                .testTarget(name: "AlamofireTests",
                                            dependencies: ["Alamofire"],
                                            path: "Tests")],
                      swiftLanguageVersions: [.v5])
 */
