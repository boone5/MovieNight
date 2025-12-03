import BundlePlugin
import ProjectDescription

let project = Project(
    name: "App",
    targets: [
        .target(
            name: "App",
            destinations: [.iPhone, .iPad],
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
                .project(target: "Networking", path: "Frameworks"),
                .external(name: "SwiftUITrackableScrollView"),
                .external(name: "YouTubePlayerKit")
            ],
            coreDataModels: [
                .coreDataModel("CoreData/FilmContainer.xcdatamodeld"),
                .coreDataModel("CoreData/MovieNight.xcdatamodeld"),
            ]
        ),
        .target(
            name: "AppTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: .bundleId(for: "MovieNightTests"),
            infoPlist: .default,
            sources: ["App/Tests/**"],
            resources: [],
            dependencies: [.target(name: "App")]
        ),
        .target(
            name: "AppUITests",
            destinations: .iOS,
            product: .uiTests,
            bundleId: .bundleId(for: "MovieNightUITests"),
            infoPlist: .default,
            sources: ["App/UITests/**"],
            resources: [],
            dependencies: [.target(name: "App")]
        ),
    ],
)
