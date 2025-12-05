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
                .project(.networking, from: .frameworks),
                .external(name: "SwiftUITrackableScrollView"),
                .external(name: "YouTubePlayerKit")
            ],
            coreDataModels: [
                .coreDataModel("CoreData/FilmContainer.xcdatamodeld"),
                .coreDataModel("CoreData/MovieNight.xcdatamodeld"),
            ]
        ),
        .unitTests(for: .app),
        .uiTests(for: .app)
    ],
)
