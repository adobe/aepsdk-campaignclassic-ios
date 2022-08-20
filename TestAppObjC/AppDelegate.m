/*
 Copyright 2022 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License")
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
 */

#import "AppDelegate.h"
@import AEPCore;
@import AEPServices;
@import AEPAssurance;
@import AEPCampaignClassic;
@import UserNotifications;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [AEPMobileCore setLogLevel: AEPLogLevelTrace];
    [AEPMobileCore registerExtensions:@[AEPMobileCampaignClassic.class] completion:^{
        // For testing use the appID from tag property "Pravin ACC (For Swift SDK)" in org "OBUMobile5"
        [AEPMobileCore configureWithAppId:@""];
    }];
    [self registerForRemoteNotifications];
    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken{
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys: @"Hello", @"testString", nil]; //nil to signify end of objects and keys.
    [params setObject: [NSNumber numberWithInt:12345] forKey: @"testNum"];
    [params setObject: [NSNumber numberWithBool:YES]  forKey: @"testBool"];
    
    // Call public API registerDevice to register device token with configured ACC server instance
    [AEPMobileCampaignClassic registerDeviceWithToken:deviceToken userKey:@"JohnDoe" additionalParameters:params];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Failed to Register for Notification: %@", error);
}


- (void)registerForRemoteNotifications {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    // Request authorization to display alerts, play sounds or badge app's icon
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionProvidesAppNotificationSettings) completionHandler:^(BOOL granted, NSError * _Nullable error){
        if(!error){
            dispatch_async(dispatch_get_main_queue(), ^{
                // This will result in either application:didRegisterForRemoteNotificationsWithDeviceToken: or application:didFailToRegisterForRemoteNotificationsWithError: to be called on the application delegate
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            });
        }
    }];
}

/* Handle push from foreground: The method will be called on the delegate only if the application is in the foreground. The application can choose to have the notification presented as a sound, badge, alert and/or in the notification list. */
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    
    // Call public API trackNotificationReceive to notify the configured ACC server instance that the message was received
    [AEPMobileCampaignClassic trackNotificationReceiveWithUserInfo:notification.request.content.userInfo];
    completionHandler(UNNotificationPresentationOptionSound  | UNNotificationPresentationOptionBadge);
}

/* Handle push from background or closed : The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. */
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler{
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    [AEPMobileCampaignClassic trackNotificationClickWithUserInfo:userInfo];
    completionHandler();
}

#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


@end
