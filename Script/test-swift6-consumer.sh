#!/bin/bash

set -e # Any subsequent(*) commands which fail will cause the shell script to exit immediately

PROJECT_NAME=Swift6Consumer

# Clean up.
rm -rf $PROJECT_NAME

mkdir -p $PROJECT_NAME/Sources/$PROJECT_NAME $PROJECT_NAME/Sources/${PROJECT_NAME}MainActor && cd $PROJECT_NAME

# Create the Package.swift. Tools version 6.2 is required for swiftLanguageMode and defaultIsolation, and only the consumer targets use Swift 6.
echo "// swift-tools-version:6.2
import PackageDescription
let package = Package(
    name: \"$PROJECT_NAME\",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: \"$PROJECT_NAME\", targets: [\"$PROJECT_NAME\", \"${PROJECT_NAME}MainActor\"])
    ],
    dependencies: [
        .package(name: \"AEPCampaignClassic\", path: \"../\")
    ],
    targets: [
        .target(
            name: \"$PROJECT_NAME\",
            dependencies: [
                .product(name: \"AEPCampaignClassic\", package: \"AEPCampaignClassic\")
            ],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .target(
            name: \"${PROJECT_NAME}MainActor\",
            dependencies: [
                .product(name: \"AEPCampaignClassic\", package: \"AEPCampaignClassic\")
            ],
            swiftSettings: [.swiftLanguageMode(.v6), .defaultIsolation(MainActor.self)]
        )
    ]
)
" >Package.swift

# A main actor consumer calls every public API, the same way a Swift 6 app does from UI code.
CONSUMER_SOURCE="import Foundation
import AEPCore
import AEPCampaignClassic

@MainActor
final class CampaignClassicConsumer {
    func exercise(token: Data, userInfo: [AnyHashable: Any]) {
        MobileCore.registerExtensions([CampaignClassic.self])
        CampaignClassic.registerDevice(token: token, userKey: \"user@example.com\", additionalParameters: [\"key\": \"value\"])
        CampaignClassic.registerDevice(token: token, userKey: nil, additionalParameters: nil)
        CampaignClassic.trackNotificationReceive(withUserInfo: userInfo)
        CampaignClassic.trackNotificationClick(withUserInfo: userInfo)
        _ = CampaignClassic.extensionVersion
    }
}
"
echo "$CONSUMER_SOURCE" >Sources/$PROJECT_NAME/$PROJECT_NAME.swift
echo "$CONSUMER_SOURCE" >Sources/${PROJECT_NAME}MainActor/${PROJECT_NAME}MainActor.swift

swift package resolve

echo '############# Build Swift 6 consumer for generic iOS device ###############'
xcodebuild build -scheme $PROJECT_NAME -destination 'generic/platform=iOS'

echo '############# Build Swift 6 consumer for generic iOS Simulator ###############'
xcodebuild build -scheme $PROJECT_NAME -destination 'generic/platform=iOS Simulator'

# Clean up.
cd ../
rm -rf $PROJECT_NAME
