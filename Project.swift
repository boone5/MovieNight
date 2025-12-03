import ProjectDescription

let project = Project(
    name: "MovieNight",
    targets: [
        .target(
            name: "MovieNight",
            destinations: [.iPhone, .iPad],
            product: .app,
            bundleId: "com.hunterboone.MovieNight",
            deploymentTargets: .iOS("26.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["MovieNight/Sources/**"],
            resources: ["MovieNight/Resources/**"],
            dependencies: [
                .external(name: "SwiftUITrackableScrollView"),
                .external(name: "YouTubePlayerKit")
            ],
            coreDataModels: [
                .coreDataModel("CoreData/FilmContainer.xcdatamodeld"),
                .coreDataModel("CoreData/MovieNight.xcdatamodeld"),
            ]
        ),
        .target(
            name: "MovieNightTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.hunterboone.MovieNightTests",
            infoPlist: .default,
            sources: ["MovieNight/Tests/**"],
            resources: [],
            dependencies: [.target(name: "MovieNight")]
        ),
        .target(
            name: "MovieNightUITests",
            destinations: .iOS,
            product: .uiTests,
            bundleId: "com.hunterboone.MovieNightTests",
            infoPlist: .default,
            sources: ["MovieNight/UITests/**"],
            resources: [],
            dependencies: [.target(name: "MovieNight")]
        ),
    ],
)
