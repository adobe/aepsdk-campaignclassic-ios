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

    /// Retrieves the broadlogId string from the event data if available and not empty, nil otherwise
    var broadlogId: String? {
        guard let broadlogId = trackingInfo?[CampaignClassicConstants.EventDataKeys.CampaignClassic.TRACK_INFO_KEY_BROADLOG_ID] as? String, !broadlogId.isEmpty else {
            return nil
        }
        return broadlogId
    }

    /// Retrieves the deliveryId string from the event data if available and not empty, nil otherwise
    var deliveryId: String? {
        guard let deliveryId = trackingInfo?[CampaignClassicConstants.EventDataKeys.CampaignClassic.TRACK_INFO_KEY_DELIVERY_ID] as? String, !deliveryId.isEmpty else {
            return nil
        }
        return deliveryId
    }

    /// Retrieves the deviceToken string from the event data if available and not empty, nil otherwise
    var deviceToken: String? {
        guard let deviceToken = data?[CampaignClassicConstants.EventDataKeys.CampaignClassic.DEVICE_TOKEN] as? String, !deviceToken.isEmpty else {
            return nil
        }
        return deviceToken
    }

    /// Retrieves the `userKey` string from the event data if available and not empty, nil otherwise
    var userKey: String? {
        guard let userKey = data?[CampaignClassicConstants.EventDataKeys.CampaignClassic.USER_KEY] as? String, !userKey.isEmpty else {
            return nil
        }
        return userKey
    }

    /// Retrieves the `additionalParameters` anycodable dictionary from event data if available, nil otherwise
    var additionalParameters: [String: AnyCodable]? {
        return data?[CampaignClassicConstants.EventDataKeys.CampaignClassic.ADDITIONAL_PARAMETERS] as? [String: AnyCodable]
    }

    /// Retrieves the deviceInfo dictionary from event data if available, nil otherwise
    var deviceInfo: [String: String]? {
        return data?[CampaignClassicConstants.EventDataKeys.CampaignClassic.DEVICE_INFO] as? [String: String]
    }

    private var trackingInfo: [String: Any]? {
        return data?[CampaignClassicConstants.EventDataKeys.CampaignClassic.TRACK_INFO] as? [String: Any]
    }
}
