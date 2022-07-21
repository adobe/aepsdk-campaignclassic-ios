# Adobe Experience Platform Campaign Classic SDK

[![Cocoapods](https://img.shields.io/cocoapods/v/AEPCampaignClassic.svg?color=orange&label=AEPCampaignClassic&logo=apple&logoColor=white)](https://cocoapods.org/pods/AEPCampaignClassic)

[![SPM](https://img.shields.io/badge/SPM-Supported-orange.svg?logo=apple&logoColor=white)](https://swift.org/package-manager/)
[![CircleCI](https://img.shields.io/circleci/project/github/adobe/aepsdk-campaignclassic-ios/main.svg?logo=circleci)](https://circleci.com/gh/adobe/workflows/aepsdk-campaignclassic-ios)
[![Code Coverage](https://img.shields.io/codecov/c/github/adobe/aepsdk-campaignclassic-ios/main.svg?logo=codecov)](https://codecov.io/gh/adobe/aepsdk-campaignclassic-ios/branch/main)

## About this project

The AEPCampaignClassic extension represents the Campaign Classic Adobe Experience Platform SDK that is required for registering mobile devices and sending push notification click-through feedback to a Campaign Classic marketing server.

## Requirements
- Xcode 11.x
- Swift 5.x

## Installation
These are currently the supported installation options:

### [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)
```ruby
# Podfile
use_frameworks!

# For app development, include all the following pods
target 'YOUR_TARGET_NAME' do
    pod 'AEPCampaignClassic'
    pod 'AEPCore'
    pod 'AEPServices'
    pod `AEPLifecycle`
end

# For extension development, include AEPCampaignClassic and its dependencies
target 'YOUR_TARGET_NAME' do
    pod 'AEPCampaignClassic'
    pod 'AEPCore'
    pod 'AEPServices'
    pod `AEPLifecycle`
end
```

Replace `YOUR_TARGET_NAME` and then, in the `Podfile` directory, type:

```bash
$ pod install
```

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

To add the AEPCampaignClassic Package to your application, from the Xcode menu select:

`File > Swift Packages > Add Package Dependency...`

Enter the URL for the AEPCampaignClassic package repository: `https://github.com/adobe/aepsdk-campaignclassic-ios.git`. Click Next

Specify the Version rule for the package options. Click Next and Finish.

Alternatively, if your project has a `Package.swift` file, you can add AEPCampaignClassic directly to your dependencies:

```swift
dependencies: [
    .package(name: "AEPCampaignClassic", url: "https://github.com/adobe/aepsdk-campaignclassic-ios.git", .upToNextMajor(from: "3.0.0"))
],
targets: [
    .target(name: "YourTarget",
            dependencies: ["AEPCampaignClassic"],
            path: "your/path")
]
```

### Project Reference

Include `AEPCampaignClassic.xcodeproj` in the targeted Xcode project and link all necessary libraries to your app target.

### Binaries

Run `make archive` from the root directory to generate `.xcframeworks` for each module under the `build` folder. Drag and drop all `.xcframeworks` to your app target in Xcode.

## Documentation

Additional documentation for usage and SDK architecture can be found under the [Documentation](Documentation/README.md) directory.

## Related Projects

| Project                                                      | Description                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| [AEPCore Extensions](https://github.com/adobe/aepsdk-core-ios) | The AEPCore extensions provide a common set of functionality and services required by all the Mobile SDK extensions. |

## Contributing

Contributions are welcome! Read the [Contributing Guide](./.github/CONTRIBUTING.md) for more information.

## Licensing

This project is licensed under the Apache V2 License. See [LICENSE](LICENSE) for more information.
