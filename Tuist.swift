import ProjectDescription

let tuist = Config(
    project: .tuist(
        compatibleXcodeVersions: .upToNextMajor("26"),
        plugins: [
            .local(path: .relativeToRoot("Plugin"))
        ]
    )
)