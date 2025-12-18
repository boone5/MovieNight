// swift-tools-version: 5.9
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        productTypes: [
            "ComposableArchitecture": .framework,
            "Clocks": .framework,
            "CoreSupport": .framework,
            "SwiftNavigation": .framework,
            "XCTestDynamicOverlay": .framework,
            "CasePaths": .framework,
            "CombineSchedulers": .framework,
            "ConcurrencyExtras": .framework,
            "CustomDump": .framework,
            "Dependencies": .framework,
            "DependenciesMacros": .framework,
            "IdentifiedCollections": .framework,
            "IssueReporting": .framework,
            "OrderedCollections": .framework,
            "_CollectionsUtilities": .framework,
            "Perception": .framework,
            "PerceptionCore": .framework,
            "Sharing": .framework,
            "Sharing1": .framework,
            "Sharing2": .framework,
            "SwiftUINavigation": .framework,
            "SwiftUINavigationCore": .framework,
            "UIKitNavigation": .framework,
            "DequeModule": .framework,
            "YouTubePlayerKit": .framework,
            "FortuneWheel": .framework
        ],
        targetSettings: [
            "ComposableArchitecture": .settings(base: [
                "OTHER_SWIFT_FLAGS": ["-module-alias", "Sharing=SwiftSharing"]
            ]),
            "Sharing": .settings(base: [
                "PRODUCT_NAME": "SwiftSharing",
                "OTHER_SWIFT_FLAGS": ["-module-alias", "Sharing=SwiftSharing"]
            ])
        ]
    )
#endif

let package = Package(
    name: "MovieNight",
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.20.2"),
        .package(url: "https://github.com/SvenTiigi/YouTubePlayerKit.git", from: "2.0.0"),
        .package(url: "https://github.com/aking618/FortuneWheel.git", branch: "master"),
    ],
)
