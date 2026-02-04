import BundlePlugin
import ProjectDescription

let project = Project(
    name: ProjectReference.frameworks.rawValue,
    settings: .settings(
        base: [
            "OTHER_LDFLAGS": .otherLDFlags
        ]
    ),
    targets: [
        .target(
            framework: .networking,
            dependencies: [
                .target(.logger),
                .target(.models),
                .external(.composableArchitecture),
            ]
        ),
        .target(
            framework: .logger,
            dependencies: [
                .external(.composableArchitecture),
            ]
        ),
        .target(
            framework: .models,
            dependencies: [
                .external(.composableArchitecture),
            ],
            coreDataModels: [
                .coreDataModel("../CoreData/FilmContainer.xcdatamodeld"),
                .coreDataModel("../CoreData/MovieNight.xcdatamodeld"),
            ]
        ),
        .target(
            framework: .search,
            dependencies: [
                .target(.logger),
                .target(.models),
                .target(.networking),
                .target(.ui),
                .external(.composableArchitecture),
            ]
        ),
        .target(
            framework: .ui,
            resources: .resources(.ui),
            infoPlist: .extendingDefault(
                with: [
                    "UIAppFonts": [
                        "Montserrat-Italic-VariableFont_wght.ttf",
                        "Montserrat-VariableFont_wght.ttf",
                        "OpenSans-Italic-VariableFont_wdth,wght.ttf",
                        "OpenSans-VariableFont_wdth,wght.ttf",
                    ]
                ]
            ),
            dependencies: [
                .target(.logger),
                .target(.models),
                .target(.networking),
                .external(.composableArchitecture),
                .external(name: "YouTubePlayerKit")
            ]
        ),
        .target(
            framework: .watchLater,
            dependencies: [
                .target(.logger),
                .target(.models),
                .target(.networking),
                .target(.ui),
                .external(.composableArchitecture),
                .external(.fortuneWheel),
                .external(.confettiSwiftUI)
            ]
        ),
        .target(
            framework: .account,
            dependencies: [
                .target(.logger),
                .target(.networking),
                .target(.ui),
                .external(.composableArchitecture)
            ]
        )
    ],
    resourceSynthesizers: .default.filter { $0 != .fonts() }
)
