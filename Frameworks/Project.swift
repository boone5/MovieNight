import BundlePlugin
import ProjectDescription

let project = Project(
    name: "Frameworks",
    targets: [
        .target(
            name: "Networking",
            destinations: [.iPhone, .iPad],
            product: .framework,
            bundleId: .bundleId(for: "Networking"),
            infoPlist: .default,
            sources: ["Networking/Sources/**"],
            resources: [],
        )
    ]
)
