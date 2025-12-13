import BundlePlugin
import ProjectDescription

let project = Project(
    name: "App",
    targets: [
        .target(
            name: "App",
            destinations: .iOS,
            product: .app,
            bundleId: .bundleId(for: "MovieNight"),
            deploymentTargets: .minimumDeploymentTarget,
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["App/Sources/**"],
            resources: ["App/Resources/**"],
            dependencies: [
                .project(.logger, from: .frameworks),
                .project(.models, from: .frameworks),
                .project(.networking, from: .frameworks),
                .project(.search, from: .frameworks),
                .project(.ui, from: .frameworks),
                .project(.watchLater, from: .frameworks),
                .external(.composableArchitecture),
                .external(name: "YouTubePlayerKit"),
            ],
            settings: .settings(
                base: [
                    "OTHER_LDFLAGS": .otherLDFlags
                ]
            )
        ),
        .unitTests(for: .app),
        .uiTests(for: .app)
    ],
)
