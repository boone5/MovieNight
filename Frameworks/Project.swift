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
                .external(.composableArchitecture),
            ]
        ),
        .target(
            framework: .logger,
            dependencies: [
                .external(.composableArchitecture),
            ]
        ),
    ]
)
