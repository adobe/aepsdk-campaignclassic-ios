# Getting started with AEPCampaignClassic SDK

## Configure Campaign Classic extension in the Data Collection UI

1. In the Data Collection UI, click the **Extensions** tab.
2. On the **Catalog** tab, locate the **Adobe Campaign Classic** extension, and click **Install**.
3. Type in the settings for your extension.
4. Click **Save**.
5. Complete the publishing process to update the SDK configuration.

   For more information about publishing, see the [publishing overview](https://experienceleague.adobe.com/docs/launch/using/publish/overview.html).

> **Note**
> You can retrieve your Campaign Classic registration or tracking endpoint URLs in the Campaign Classic interface under the **Tools > Advanced > Deployment wizard** menu. The endpoint for push notifications is usually the same as the URL that is used for web forms and surveys.

#### Registration endpoints

Type the registration endpoint URL(s) for your Campaign Classic instances. You can specify up to three unique endpoints for your development, staging, and production environments.

> **Warning**
> For this extension, the registration endpoint URLs should be entered **without** a prefixing `https://`.

#### Tracking endpoints

Type the tracking endpoint URL(s) for your Campaign Classic instances. Like the registration URLs, you can specify up to three unique endpoints for your development, staging, and production environments.

> **Warning**
> For this extension, the tracking endpoint URLs should be entered **without** a prefixing `https://`.

#### Integration key (iOS)

You can specify up to three unique iOS integration keys for your development, staging, and production environments. iOS integration keys are generated after creating a service that contains iOS applications using the [Campaign Classic client console](https://experienceleague.adobe.com/docs/campaign-classic/using/installing-campaign-classic/connect-to-campaign/installing-the-client-console.html). For more information on where to find the integration key, see the tutorial on [configuring the mobile application in Adobe Campaign](https://experienceleague.adobe.com/docs/campaign-classic/using/sending-messages/sending-push-notifications/configure-the-mobile-app/configuring-the-mobile-application-ios.html).

#### Request timeout

The request timeout is the amount of time, in seconds, to wait for a response from the registration or tracking endpoint before timing out. The SDK default timeout value is 30 seconds.

## Add the AEPCampaignClassic extension to your app

The Campaign Classic extension depends on the Mobile Core and requires the Lifecycle extension to collect application launch metrics. Install the following extensions with your preferred dependency manager.

- [Mobile Core](https://github.com/adobe/aepsdk-core-ios)

### [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

Add the following pods to your `Podfile`:

```ruby
# Podfile
use_frameworks!

target 'YOUR_TARGET_NAME' do
    pod 'AEPCampaignClassic'
    pod 'AEPCore'
    pod 'AEPServices'
    pod 'AEPLifecycle'
end
```

Replace `YOUR_TARGET_NAME` and then, in the `Podfile` directory, type:

```bash
$ pod install
```

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

To add the AEPCampaignClassic package to your application, from the Xcode menu select:

`File > Add Package Dependencies...`

> **Note**
> The menu options may vary depending on the version of Xcode being used.

Enter the URL for the AEPCampaignClassic package repository: `https://github.com/adobe/aepsdk-campaignclassic-ios.git`.

For `Dependency Rule`, select `Up to Next Major Version`, then click `Add Package`.

Alternatively, if your project has a `Package.swift` file, you can add AEPCampaignClassic directly to your dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/adobe/aepsdk-campaignclassic-ios.git", .upToNextMajor(from: "5.0.0"))
],
targets: [
    .target(name: "YourTarget",
            dependencies: ["AEPCampaignClassic"],
            path: "your/path")
]
```

### Binaries

To generate an `.xcframework` for the AEPCampaignClassic extension, run the following command from the root directory:

```bash
make archive
```

This generates the XCFramework under the `build` folder. Drag and drop all the `.xcframework`s to your app target in Xcode.

## Register the Campaign Classic extension with Mobile Core

Import the AEPCampaignClassic framework and its dependencies, then register the Campaign Classic and Lifecycle extensions in the `application(_:didFinishLaunchingWithOptions:)` method in your `AppDelegate`:

#### Swift

```swift
import AEPCampaignClassic
import AEPCore
import AEPLifecycle
import AEPServices

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // optionally enable debug logging
        MobileCore.setLogLevel(.trace)

        let extensions = [
            CampaignClassic.self,
            Lifecycle.self
        ]

        MobileCore.registerExtensions(extensions) {
            // use the App ID assigned to this application in Adobe Data Collection
            MobileCore.configureWith(appId: "YOUR_APP_ENVIRONMENT_ID")
        }

        return true
    }
}
```

#### Objective-C

```objc
@import AEPCampaignClassic;
@import AEPCore;
@import AEPLifecycle;
@import AEPServices;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // optionally enable debug logging
    [AEPMobileCore setLogLevel:AEPLogLevelTrace];

    [AEPMobileCore registerExtensions:@[AEPMobileCampaignClassic.class, AEPMobileLifecycle.class] completion:^{
        // use the App ID assigned to this application in Adobe Data Collection
        [AEPMobileCore configureWithAppId:@"YOUR_APP_ENVIRONMENT_ID"];
    }];

    return YES;
}

@end
```

## Configuration keys

To update the SDK configuration programmatically, use the following information to change the Campaign Classic configuration values. For more information, see the [Configuration API reference](https://github.com/adobe/aepsdk-core-ios).

| Key | Required | Description | Data Type |
| :--- | :--- | :--- | :--- |
| `build.environment` | Yes | Specifies which environment to use (prod, dev, or staging) when sending registration and tracking information. It is also used to specify which mobile app integration key to use. | String |
| `campaignclassic.timeout` | No | Specifies the amount of time, in seconds, to wait for a response from the Campaign Classic registration or tracking server. | Integer |
| `campaignclassic.marketingServer` | Yes | Sets the marketing server, which receives registration requests. | String |
| `campaignclassic.trackingServer` | Yes | Sets the tracking server, which receives tracking requests. | String |
| `campaignclassic.ios.integrationKey` | Yes | Sets the iOS mobile app integration key, which links the app to an iOS application campaign in Campaign Classic. | String |

## Next steps

- Get familiar with the various APIs offered by the Adobe Campaign Classic SDK by checking out the [Campaign Classic API reference](./api-reference.md).
