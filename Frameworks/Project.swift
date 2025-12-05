import BundlePlugin
import ProjectDescription

let project = Project(
    name: ProjectReference.frameworks.rawValue,
    targets: [
        .target(
            framework: .networking,
            dependencies: [
                .external(.composableArchitecture),
            ]
        )
    ]
)
