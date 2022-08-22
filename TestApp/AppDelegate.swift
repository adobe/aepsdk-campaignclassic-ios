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

import Foundation
import UIKit
import UserNotifications
import AEPCore
import AEPServices
import AEPLifecycle
import AEPAssurance
import AEPCampaignClassic



class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var pushDetails = PushNotificationDetailClass()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        MobileCore.setLogLevel(.trace)
        let extensions = [Lifecycle.self,
                          Assurance.self,
                          CampaignClassic.self
        ]
        MobileCore.registerExtensions(extensions, {
            // For testing use the appID from tag property "Pravin ACC (For Swift SDK)" in org "OBUMobile5"
            MobileCore.configureWith(appId: "")
        })
        UNUserNotificationCenter.current().delegate = self
        requestNotificationPermission()
        return true
    }
    
    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge, .providesAppNotificationSettings]) { granted, error in
            if let error = error {
                print("Error retrieving notification permission \(error.localizedDescription)")
            }
            guard granted else { return }
            self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        print("Notification settings: \(settings)")
          guard settings.authorizationStatus == .authorized else { return }
          DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
          }
      }
    }
        
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        CampaignClassic.registerDevice(token: deviceToken, userKey: "johnDoe", additionalParameters: ["email" : "john@email.com"])
        let token = deviceToken.reduce("") {$0 + String(format: "%02X", $1)}
        pushDetails.pushToken = token
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Fail to Register for Remote Notification with Error \(error.localizedDescription)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge,.list,.banner,.sound])
        CampaignClassic.trackNotificationReceive(withUserInfo: notification.request.content.userInfo)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        CampaignClassic.trackNotificationClick(withUserInfo: response.notification.request.content.userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        CampaignClassic.trackNotificationReceive(withUserInfo: userInfo)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        // handle user clicking on App's Notification Setting from Settings->TestApp->Notifications->TestApp Notification Settings
    }
    
    
}
