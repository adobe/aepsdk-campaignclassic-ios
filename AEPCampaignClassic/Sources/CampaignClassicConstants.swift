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
import Foundation

enum CampaignClassicConstants {
    static let EXTENSION_NAME                           = "com.adobe.module.campaignclassic"
    static let FRIENDLY_NAME                            = "CampaignClassic"
    static let EXTENSION_VERSION                        = "5.0.0"
    static let LOG_TAG                                  = FRIENDLY_NAME

    // general strings
    static let DATASTORE_KEY = "ADOBEMOBILE_CAMPAIGNCLASSIC"
    static let REGISTRATION_API_URL_BASE = "https://%@/nms/mobile/1/registerIOS.jssp"
    static let TRACKING_API_URL_BASE = "https://%@/r/?id=h%@,%@,%@"
    // swiftlint:disable line_length
    static let REGISTRATION_PAYLOAD_FORMAT = "registrationToken=%@&mobileAppUuid=%@&userKey=%@&deviceName=%@&deviceModel=%@&deviceBrand=%@&deviceManufacturer=%@&osName=%@&osVersion=%@&osLanguage=%@&additionalParams="
    // swiftlint:enable line_length
    static let REGISTER_PARAM_DEVICE_BRAND_APPLE = "Apple"
    static let REGISTER_PARAM_DEVICE_MANUFACTURER_APPLE = REGISTER_PARAM_DEVICE_BRAND_APPLE
    static let TRACK_RECEIVE_TAG_ID = "1"
    static let TRACK_CLICK_TAG_ID = "2"
    static let HEADER_CONTENT_TYPE_UTF8_CHARSET = "charset=UTF-8"
    static let HEADER_KEY_CONTENT_LENGTH = "Content-Length"

    enum DatastoreKeys {
        static let TOKEN_HASH = "ADOBEMOBILE_STOREDDEFAULTS_TOKENHASH"
    }

    enum EventName {
        static let DEVICE_REGISTRATION_STATUS = "Device Registration Status"
        static let REGISTER_DEVICE = "CampaignClassic Device Registration"
        static let TRACK_NOTIFICATION_CLICK = "CampaignClassic Track Notification Click"
        static let TRACK_NOTIFICATION_RECEIVE = "CampaignClassic Track Notification Receive"
    }

    enum Default {
        static let PRIVACY_STATUS: PrivacyStatus = .unknown
        static let NETWORK_TIMEOUT = TimeInterval(30)
    }

    enum EventDataKeys {

        enum CampaignClassic {
            static let SHARED_STATE_NAME = "com.adobe.module.campaignclassic"
            static let REGISTER_DEVICE = "registerdevice"
            static let TRACK_RECEIVE = "trackreceive"
            static let TRACK_CLICK = "trackclick"
            static let DEVICE_TOKEN = "devicetoken"
            static let USER_KEY = "userkey"
            static let ADDITIONAL_PARAMETERS = "additionalparameters"
            static let REGISTRATION_STATUS = "registrationstatus"
            static let TRACK_INFO = "trackinfo"
            static let TRACK_INFO_KEY_DELIVERY_ID = "_dId"
            static let TRACK_INFO_KEY_BROADLOG_ID = "_mId"
        }

        enum Configuration {
            static let EXTENSION_NAME = "com.adobe.module.configuration"
            static let GLOBAL_CONFIG_PRIVACY = "global.privacy"
            static let CAMPAIGNCLASSIC_NETWORK_TIMEOUT = "campaignclassic.timeout"
            static let CAMPAIGNCLASSIC_MARKETING_SERVER = "campaignclassic.marketingServer"
            static let CAMPAIGNCLASSIC_TRACKING_SERVER = "campaignclassic.trackingServer"
            static let CAMPAIGNCLASSIC_INTEGRATION_KEY = "campaignclassic.ios.integrationKey"
        }

    }
}
