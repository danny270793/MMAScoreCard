// swift-tools-version: 6.2
import PackageDescription

let package = Package(
  name: "ScoreCardKit",
  defaultLocalization: "en",
  platforms: [.iOS(.v26), .macOS(.v26)],
  products: [
    .library(name: "ScoreCardCore", targets: ["ScoreCardCore"]),
    .library(name: "ScoreCardData", targets: ["ScoreCardData"]),
  ],
  dependencies: [
    .package(url: "https://github.com/scinfu/SwiftSoup", from: "2.14.0"),
  ],
  targets: [
    // Pure domain: entities, streaks, octagon time, grouping and search. No I/O.
    .target(name: "ScoreCardCore"),
    // Sherdog scraper, on-device cache and the cache-aware repository.
    .target(
      name: "ScoreCardData",
      dependencies: ["ScoreCardCore", .product(name: "SwiftSoup", package: "SwiftSoup")]
    ),
    .testTarget(name: "ScoreCardCoreTests", dependencies: ["ScoreCardCore"]),
    .testTarget(name: "ScoreCardDataTests", dependencies: ["ScoreCardData"], resources: [.copy("Fixtures")]),
  ]
)
