# Campaign Classic API reference

## Prerequisites

Refer to the [Getting started guide](./getting-started.md).

## API reference

- [extensionVersion](#extensionversion)
- [registerDevice](#registerdevice)
- [trackNotificationReceive](#tracknotificationreceive)
- [trackNotificationClick](#tracknotificationclick)

---

## extensionVersion

Returns the version of the Campaign Classic extension that is registered with the Mobile Core extension.

#### Swift

**Syntax**

```swift
static var extensionVersion: String
```

**Example**

```swift
let version = CampaignClassic.extensionVersion
```

#### Objective-C

**Syntax**

```objc
+ (nonnull NSString*) extensionVersion;
```

**Example**

```objc
NSString *version = [AEPMobileCampaignClassic extensionVersion];
```

---

## registerDevice

Registers a device with the configured Adobe Campaign Classic server instance.

> **Note**
> To prepare your app to handle push notifications, see Apple's documentation on [registering your app with APNs](https://developer.apple.com/documentation/usernotifications/registering_your_app_with_apns). After you receive the APNs device token in `application(_:didRegisterForRemoteNotificationsWithDeviceToken:)`, send this token and the device information to Campaign Classic by using the `registerDevice` API.

The `registerDevice` API takes the APNs device token as a parameter, along with an optional user key that identifies a user (such as an email address or a login name). You can also provide a dictionary of custom key-value pairs that you want to associate with the registration.

#### Swift

**Syntax**

```swift
static func registerDevice(token: Data, userKey: String?, additionalParameters: [String: Any]?)
```

- _token_ is the unique APNs device token received after registering your app with APNs.
- _userKey_ is an optional `String` containing the user identifier.
- _additionalParameters_ is an optional dictionary of custom key-value pairs to be sent along with the registration call.

**Example**

```swift
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    // Create a dictionary of additional parameters
    let additionalParameters: [String: Any] = [
        "name": "John",
        "serial": 12345,
        "premium": true
    ]

    // Send the registration info
    CampaignClassic.registerDevice(token: deviceToken, userKey: "john@example.com", additionalParameters: additionalParameters)
}
```

#### Objective-C

**Syntax**

```objc
+ (void) registerDeviceWithToken: (nonnull NSData*) token userKey: (nullable NSString*) userKey additionalParameters: (nullable NSDictionary<NSString*, id>*) additionalParameters;
```

**Example**

```objc
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Create a dictionary of additional parameters
    NSMutableDictionary *additionalParameters = [NSMutableDictionary dictionary];
    [additionalParameters setObject:@"John" forKey:@"name"];
    [additionalParameters setObject:[NSNumber numberWithInt:12345] forKey:@"serial"];
    [additionalParameters setObject:[NSNumber numberWithBool:YES] forKey:@"premium"];

    // Send the registration info
    [AEPMobileCampaignClassic registerDeviceWithToken:deviceToken userKey:@"john@example.com" additionalParameters:additionalParameters];
}
```

---

## trackNotificationReceive

Sends the received push notification's tracking information to the configured Adobe Campaign Classic server. Use this API to send tracking info when a notification is received (for example, on a silent push).

> **Note**
> If `userInfo` does not contain the necessary tracking identifiers, `messageId` (`_mId`) and `deliveryId` (`_dId`), a track request is **not** sent.

#### Swift

**Syntax**

```swift
static func trackNotificationReceive(withUserInfo userInfo: [AnyHashable: Any])
```

- _userInfo_ is a dictionary containing the `_mId` and `_dId` received in the push message payload.

**Example**

```swift
func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    // Send the tracking information for a received message
    CampaignClassic.trackNotificationReceive(withUserInfo: userInfo)
    completionHandler(.noData)
}
```

#### Objective-C

**Syntax**

```objc
+ (void) trackNotificationReceiveWithUserInfo: (nonnull NSDictionary<NSString*, NSString*>*) userInfo;
```

**Example**

```objc
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // Send the tracking information for a received message
    [AEPMobileCampaignClassic trackNotificationReceiveWithUserInfo:userInfo];
    completionHandler(UIBackgroundFetchResultNoData);
}
```

---

## trackNotificationClick

Sends the clicked push notification's tracking information to the configured Adobe Campaign Classic server. Use this API to send tracking info when the application is opened following a notification click.

> **Note**
> If `userInfo` does not contain the necessary tracking identifiers, `messageId` (`_mId`) and `deliveryId` (`_dId`), a track request is **not** sent.

#### Swift

**Syntax**

```swift
static func trackNotificationClick(withUserInfo userInfo: [AnyHashable: Any])
```

- _userInfo_ is a dictionary containing the `_mId` and `_dId` received in the push message payload, or in the launch options before opening the application.

**Example**

```swift
func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    // Send the tracking information for a notification click
    CampaignClassic.trackNotificationClick(withUserInfo: response.notification.request.content.userInfo)
    completionHandler()
}
```

#### Objective-C

**Syntax**

```objc
+ (void) trackNotificationClickWithUserInfo: (nonnull NSDictionary<NSString*, NSString*>*) userInfo;
```

**Example**

```objc
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    // Send the tracking information for a notification click
    [AEPMobileCampaignClassic trackNotificationClickWithUserInfo:userInfo];
    completionHandler();
}
```
