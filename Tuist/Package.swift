// swift-tools-version: 5.9
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        productTypes: [
            "ComposableArchitecture": .framework,
            "SwiftUITrackableScrollView": .framework,
            "YouTubePlayerKit": .framework
        ]
    )
#endif

let package = Package(
    name: "MovieNight",
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.20.2"),
        .package(url: "https://github.com/maxnatchanon/trackable-scroll-view.git", branch: "master"),
        .package(url: "https://github.com/SvenTiigi/YouTubePlayerKit.git", from: "2.0.0")
    ],
)