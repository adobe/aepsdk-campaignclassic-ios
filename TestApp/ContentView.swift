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

import SwiftUI
import AEPCore
import AEPCampaignClassic
import UserNotifications

struct ContentView: View {
                
    var body: some View {
        ScrollView(.vertical) {
            Heading()
            CampaignClassicMockAPICard()
            MobileCorePrivacyAPICard()
            NotificationSettingsCard()
        }
    }
    
}

struct Heading: View {
    var body: some View {
        VStack {
            Text("Campaign Classic").padding(.top).font(.title)
            Text("version : \(CampaignClassic.extensionVersion)").font(.system(size: 13))
        }.padding()
    }
}


struct MobileCorePrivacyAPICard: View {
    var body: some View {
        VStack {
            Text("Mobile Core Privacy")
                .padding(.leading)
                .font(.title2)

            HStack{
                Button("Privacy opt out"){
                    MobileCore.setPrivacyStatus(PrivacyStatus.optedOut)
                }.buttonStyle(CustomButton())

                Button("Privacy opt in"){
                    MobileCore.setPrivacyStatus(PrivacyStatus.optedIn)
                }.buttonStyle(CustomButton())
            }.padding()
        }
    }
}

struct NotificationSettingsCard: View {
    @State var currentNotificationSettings = ""
    @State var unreadNotificationCount = 0
    @State var pushToken = "6dbc896cf883febf53b2a1c643435bd183c3fdbab35e2bac4310dab23283cd25"
    var body: some View {
        VStack {
            Spacer(minLength: 20)
            Text("Device Notification Settings")
                .padding(.leading)
                .font(.title2)

            ScrollView{
                Text(currentNotificationSettings).padding().font(.system(size: 13))
            }.onAppear(perform: loadNotificationSettings)

            Spacer(minLength: 20)
            Text("Notification Details")
                .padding([.leading,.bottom])
                .font(.title2)
            Text("Push Token: \(pushToken)").padding(.leading).font(.system(size: 13))
            Text("Delivered Notifications: \(unreadNotificationCount)").padding().font(.system(size: 13))
        }
    }
    
    func readOtherNotificationDetails() {
        UNUserNotificationCenter.current().getDeliveredNotifications(completionHandler: { notifications in
            unreadNotificationCount = notifications.count
        })
    }
    
    func loadNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            currentNotificationSettings = """
            Authorization status \t \t: \(getAuthorizationStatusString(settings.authorizationStatus))
            Notification Center Setting \t: \(getUNNotificationSettingString(settings.notificationCenterSetting))
            Sound Setting \t \t \t: \(getUNNotificationSettingString(settings.soundSetting))
            Badge Setting \t \t \t: \(getUNNotificationSettingString(settings.badgeSetting))
            Alert Setting \t \t  \t \t: \(getUNNotificationSettingString(settings.alertSetting))
            Announcement Setting \t: \(getUNNotificationSettingString(settings.announcementSetting))
            LockScreen Setting \t \t: \(getUNNotificationSettingString(settings.lockScreenSetting))
            Critical Alert Setting \t \t: \(getUNNotificationSettingString(settings.criticalAlertSetting))
            TimeSensitive Setting \t \t: \(getUNNotificationSettingString(settings.timeSensitiveSetting))
            """
        }
    }
}

struct CampaignClassicMockAPICard: View {
    var body: some View {
        VStack {
            HStack {
                Text("Mock API Calls")
                    .padding(.leading)
                    .font(.title2)
            }
            HStack {
                Button("Register Device"){
                    CampaignClassic.registerDevice(token: "6dbc896cf883febf53b2a1c643435bd183c3fdbab35e2bac4310dab23283cd25".data(using: .utf8)!, userKey: "johnDoe", additionalParameters: ["email" : "johnDoe@email.com"])
                }.buttonStyle(CustomButton())

                Button("Track Receive"){
                    CampaignClassic.trackNotificationReceive(withUserInfo: ["_mId" : "beca3338-1dd9-4559-ac52-b82ad32c255c", "_dId" : "marketingID"])
                }.buttonStyle(CustomButton())

                Button("Track Click"){
                    CampaignClassic.trackNotificationClick(withUserInfo: ["_mId" : "beca3338-1dd9-4559-ac52-b82ad32c255c", "_dId" : "marketingID"])
                }.buttonStyle(CustomButton())
            }
        }.padding()
    }
}


struct CustomButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}


private func getAuthorizationStatusString(_ auth : UNAuthorizationStatus) -> String {
    switch auth {
    case .authorized:
        return "Authorized"
    case .denied:
        return "Denied"
    case .notDetermined:
        return "Not determined"
    case .ephemeral:
        return "Ephemeral"
    case .provisional:
        return "Provisional"
    @unknown default:
        return "Unknown"
    }
}

private func getUNNotificationSettingString(_ setting : UNNotificationSetting) -> String {
    switch setting {
    case .notSupported:
        return "Not Supported"
    case .enabled:
        return "Enabled"
    case .disabled:
        return "Disabled"
    @unknown default:
        return "Unknown"
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
