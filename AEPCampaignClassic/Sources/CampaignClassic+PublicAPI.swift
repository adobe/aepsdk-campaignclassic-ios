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

import AEPCore
import AEPServices
import Foundation

/// Defines the public interface for the CampaignClassic extension
@objc
public extension CampaignClassic {

    /// Registers a device with the configured Adobe Campaign Classic server instance.
    ///
    /// - Parameters:
    ///    - token : A unique device token received after registering your app with APNs servers
    ///    - userKey : A `string` containing the user identifier
    ///    - additionalParameters : a dictionary of custom key-value pairs to be sent along with the registration call
    static func registerDevice(token: Data, userKey: String, additionalParameters: [String: Any]?) {
        let deviceInfo = [CampaignClassicConstants.EventDataKeys.CampaignClassic.DEVICE_INFO_KEY_DEVICE_NAME: UIDevice.current.name,
                          CampaignClassicConstants.EventDataKeys.CampaignClassic.DEVICE_INFO_KEY_DEVICE_MODEL: UIDevice.current.model,
                          CampaignClassicConstants.EventDataKeys.CampaignClassic.DEVICE_INFO_KEY_OS_NAME: UIDevice.current.systemName]

        var eventData = [CampaignClassicConstants.EventDataKeys.CampaignClassic.REGISTER_DEVICE: true,
                         CampaignClassicConstants.EventDataKeys.CampaignClassic.DEVICE_TOKEN: token.hexDescription,
                         CampaignClassicConstants.EventDataKeys.CampaignClassic.USER_KEY: userKey,
                         CampaignClassicConstants.EventDataKeys.CampaignClassic.DEVICE_INFO: deviceInfo] as [String: Any]

        // attach additional parameters only if they are available
        if let additionalParameters = additionalParameters {
            eventData[CampaignClassicConstants.EventDataKeys.CampaignClassic.ADDITIONAL_PARAMETERS] = AnyCodable.from(dictionary: additionalParameters)
        }

        let event = Event(name: CampaignClassicConstants.EventName.REGISTER_DEVICE,
                          type: EventType.campaign,
                          source: EventSource.requestContent,
                          data: eventData)

        MobileCore.dispatch(event: event)
    }

    /// Sends tracking information to the configured Adobe Campaign Classic server.
    /// Use this API to send tracking info when the application is opened following a notification click.
    /// If the userInfo does not contain the necessary tracking identifiers, messageId `_mId` and deliveryId `_dId`, no track request is sent.
    ///
    /// - Parameter userInfo :  a dictionary containing `_mId` and `_dId` received in the push message payload, or in the
    ///                             launch options before opening the application
    static func trackNotificationClick(withUserInfo userInfo: [String: Any]) {
        let eventData = [CampaignClassicConstants.EventDataKeys.CampaignClassic.TRACK_CLICK: true,
                         CampaignClassicConstants.EventDataKeys.CampaignClassic.TRACK_INFO: userInfo] as [String: Any]

        let event = Event(name: CampaignClassicConstants.EventName.TRACK_NOTIFICATION_CLICK,
                          type: EventType.campaign,
                          source: EventSource.requestContent,
                          data: eventData)
        MobileCore.dispatch(event: event)
    }

    /// Sends tracking information to the configured Adobe Campaign Classic server.
    /// Use this API to send tracking info on receiving a notification (silent push).
    /// If the userInfo does not contain the necessary tracking identifiers, messageId (_mId) and deliveryId (_dId), no track request is sent.
    ///
    /// - Parameter userInfo :  a dictionary containing (_mId) and (_dId) received in the push message payload, or in the
    ///                             launch options before opening the application
    static func trackNotificationReceive(withUserInfo userInfo: [String: Any]) {
        let eventData = [CampaignClassicConstants.EventDataKeys.CampaignClassic.TRACK_RECEIVE: true,
                         CampaignClassicConstants.EventDataKeys.CampaignClassic.TRACK_INFO: userInfo] as [String: Any]

        let event = Event(name: CampaignClassicConstants.EventName.TRACK_NOTIFICATION_RECEIVE,
                          type: EventType.campaign,
                          source: EventSource.requestContent,
                          data: eventData)
        MobileCore.dispatch(event: event)

    }
}

private extension Data {
    /// Returns a hex representation of the data
    var hexDescription: String {
        return reduce("") {$0 + String(format: "%02X", $1)}
    }
}
