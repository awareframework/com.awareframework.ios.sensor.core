// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "com.awareframework.ios.sensor.core",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "com.awareframework.ios.sensor.core",
            targets: ["com.awareframework.ios.sensor.core"]
        ),
    ],
    dependencies: [
        .package(url: "git@github.com:realm/realm-swift.git", from: "20.0.0"),
        .package(url: "git@github.com:SwiftyJSON/SwiftyJSON.git", from: "5.0.2"),
    ],
    targets: [
        .target(
            name: "com.awareframework.ios.sensor.core",
            dependencies: [
                .product(name: "RealmSwift", package: "realm-swift"),
                .product(name: "SwiftyJSON", package: "SwiftyJSON")
            ],
            path: "com.awareframework.ios.sensor.core/Classes"
        ),
    ],
    swiftLanguageModes: [.v5]
)
