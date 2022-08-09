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
import AEPCore

enum CampaignClassicConstants {
    static let EXTENSION_NAME                           = "com.adobe.module.campaignclassic"
    static let FRIENDLY_NAME                            = "CampaignClassic"
    static let EXTENSION_VERSION                        = "3.0.0"
    static let LOG_TAG                                  = FRIENDLY_NAME

    // general strings
    static let DATASTORE_KEY = "ADOBEMOBILE_CAMPAIGNCLASSIC"
    static let REGISTRATION_API_URL_BASE = "https://%s/nms/mobile/1/registerIOS.jssp"
    static let TRACKING_API_URL_BASE = "https://%@/r/?id=h%@,%@,%@"
    static let REGISTER_PARAMS_FORMAT = "registrationToken=%s&mobileAppUuid=%s&userKey=%s&deviceName=%s&deviceModel=%s&deviceBrand=%s&deviceManufacturer=%s&osName=%s&osVersion=%s&osLanguage=%s&additionalParams="
    static let REGISTER_PARAM_DEVICE_BRAND_APPLE = "Apple"
    static let REGISTER_PARAM_DEVICE_MANUFACTURER_APPLE = REGISTER_PARAM_DEVICE_BRAND_APPLE
    static let TRACK_RECEIVE_TAGID = "1"
    static let TRACK_CLICK_TAGID = "2"
    static let HEADER_CONTENT_TYPE_UTF8_CHARSET = "charset=UTF-8"
    static let HEADER_KEY_CONTENT_LENGTH = "Content-Length"

    enum DatastoreKeys {
        static let TOKEN_HASH = "ADOBEMOBILE_STOREDDEFAULTS_TOKENHASH"
        static let REGISTER_STATUS = "ADOBEMOBILE_STOREDDEFAULTS_REGISTERSTATUS"
    }

    enum EventName {
        static let REGISTER_DEVICE = "CampaignClassic Device Registration"
        static let TRACK_NOTIFICATION_CLICK = "CampaignClassic Track Notification Click"
        static let TRACK_NOTIFICATION_RECEIVE = "CampaignClassic Track Notification Receive"
    }

    enum Default {
        static let PRIVACY_STATUS: PrivacyStatus = .unknown
        static let NETWORK_TIMEOUT = TimeInterval(30)
    }

    enum EventDataKeys {
        static let STATE_OWNER = "stateowner"

        enum CampaignClassic {
            static let SHARED_STATE_NAME = "com.adobe.module.campaignclassic"
            static let REGISTER_DEVICE = "registerdevice"
            static let TRACK_RECEIVE = "trackreceive"
            static let TRACK_CLICK = "trackclick"
            static let DEVICE_TOKEN = "devicetoken"
            static let USER_KEY = "userkey"
            static let ADDITIONAL_PARAMETERS = "additionalparameters"
            static let DEVICE_INFO = "deviceinfo"
            static let DEVICE_INFO_KEY_DEVICE_NAME = "devicename"
            static let DEVICE_INFO_KEY_DEVICE_MODEL = "devicemodel"
            static let DEVICE_INFO_KEY_OS_NAME = "devicesystemname"
            static let REGISTRATION_STATUS = "registrationstatus"
            static let TRACK_INFO = "trackinfo"
            static let TRACK_INFO_KEY_DELIVERY_ID = "_dId"
            static let TRACK_INFO_KEY_BROADLOG_ID = "_mId"
            static let LOG_PREFIX = SHARED_STATE_NAME
        }

        enum Configuration {
            static let NAME = "com.adobe.module.configuration"
            static let GLOBAL_CONFIG_PRIVACY = "global.privacy"
            static let CAMPAIGNCLASSIC_NETWORK_TIMEOUT = "campaignclassic.timeout"
            static let CAMPAIGNCLASSIC_MARKETING_SERVER = "campaignclassic.marketingServer"
            static let CAMPAIGNCLASSIC_TRACKING_SERVER = "campaignclassic.trackingServer"
            static let CAMPAIGNCLASSIC_INTEGRATION_KEY = "campaignclassic.ios.integrationKey"
        }

        enum Lifecycle {
            static let EXTENSION_NAME = "com.adobe.module.lifecycle"
            static let LAUNCH_EVENT = "launchevent"
            static let CONTEXT_DATA = "lifecyclecontextdata"
            static let OPERATING_SYSTEM = "osversion"
            static let LOCALE = "locale"
        }
    }
}
