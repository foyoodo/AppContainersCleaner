import ProjectDescription

let project = Project(
    name: "ContainersCleaner",
    targets: [
        .target(
            name: "ContainersCleaner",
            destinations: .macOS,
            product: .app,
            bundleId: "com.foyoodo.ContainersCleaner",
            deploymentTargets: .macOS("14.0"),
            infoPlist: .default,
            sources: ["ContainersCleaner/Sources/**"],
            resources: ["ContainersCleaner/Resources/**"],
            dependencies: []
        ),
        .target(
            name: "ContainersCleanerTests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "com.foyoodo.ContainersCleanerTests",
            infoPlist: .default,
            sources: ["ContainersCleaner/Tests/**"],
            resources: [],
            dependencies: [.target(name: "ContainersCleaner")]
        ),
    ]
)
