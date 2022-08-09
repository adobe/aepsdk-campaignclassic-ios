/*
 Copyright 2022 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
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

extension Event {

    /// Returns true if this event is a Campaign Classic register event
    var isRegisterEvent: Bool {
        return data?[CampaignClassicConstants.EventDataKeys.CampaignClassic.REGISTER_DEVICE] as? Bool ?? false
    }

    /// Returns true if this event is a Campaign Classic TrackNotificationClick event
    var isTrackClickEvent: Bool {
        return data?[CampaignClassicConstants.EventDataKeys.CampaignClassic.TRACK_CLICK] as? Bool ?? false
    }

    /// Returns true if this event is a Campaign Classic TrackNotificationReceive event
    var isTrackReceiveEvent: Bool {
        return data?[CampaignClassicConstants.EventDataKeys.CampaignClassic.TRACK_RECEIVE] as? Bool ?? false
    }

    /// Retrieves the broadlogId string from the event data if available, nil otherwise
    var broadlogId: String? {
        if let trackingInfo = data?[CampaignClassicConstants.EventDataKeys.CampaignClassic.TRACK_INFO] as? [String: Any] {
            return trackingInfo[CampaignClassicConstants.EventDataKeys.CampaignClassic.TRACK_INFO_KEY_BROADLOG_ID] as? String
        }
        return nil
    }

    /// Retrieves the deliveryId string from the event data if available, nil otherwise
    var deliveryId: String? {
        if let trackingInfo = data?[CampaignClassicConstants.EventDataKeys.CampaignClassic.TRACK_INFO] as? [String: Any] {
            return trackingInfo[CampaignClassicConstants.EventDataKeys.CampaignClassic.TRACK_INFO_KEY_DELIVERY_ID] as? String
        }
        return nil
    }

    /// Retrieves the deviceToken string from the event data if available, nil otherwise
    var deviceToken: String? {
        return data?[CampaignClassicConstants.EventDataKeys.CampaignClassic.DEVICE_TOKEN] as? String
    }

    /// Retrieves the `userKey` string from the event data if available, nil otherwise
    var userKey: String? {
        return data?[CampaignClassicConstants.EventDataKeys.CampaignClassic.USER_KEY] as? String
    }

    /// Retrieves the `additionalParameters` anycodable dictionary from event data if available, nil otherwise
    var additionalParameters: [String: AnyCodable]? {
        return data?[CampaignClassicConstants.EventDataKeys.CampaignClassic.ADDITIONAL_PARAMETERS] as? [String: AnyCodable]
    }

    /// Retrieves the deviceInfo dictionary from event data if available, nil otherwise
    var deviceInfo: [String: String]? {
        return data?[CampaignClassicConstants.EventDataKeys.CampaignClassic.ADDITIONAL_PARAMETERS] as? [String: String]
    }
}
