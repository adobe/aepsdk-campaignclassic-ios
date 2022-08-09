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

struct CampaignClassicConfiguration {
    var integrationKey: String?
    var marketingServer: String?
    var trackingServer: String?
    var timeout: TimeInterval = CampaignClassicConstants.Default.NETWORK_TIMEOUT
    var privacyStatus: PrivacyStatus = CampaignClassicConstants.Default.PRIVACY_STATUS

    init(forEvent event: Event, runtime: ExtensionRuntime) {
        guard let configSharedState = runtime.getSharedState(extensionName: CampaignClassicConstants.EventDataKeys.Configuration.NAME, event: event, barrier: false)?.value else {
            return
        }
        
        marketingServer = configSharedState[CampaignClassicConstants.EventDataKeys.Configuration.CAMPAIGNCLASSIC_MARKETING_SERVER] as? String
        trackingServer = configSharedState[CampaignClassicConstants.EventDataKeys.Configuration.CAMPAIGNCLASSIC_TRACKING_SERVER] as? String
        integrationKey = configSharedState[CampaignClassicConstants.EventDataKeys.Configuration.CAMPAIGNCLASSIC_INTEGRATION_KEY] as? String
        if let timeoutInt = configSharedState[CampaignClassicConstants.EventDataKeys.Configuration.CAMPAIGNCLASSIC_NETWORK_TIMEOUT] as? Int {
            timeout = TimeInterval(timeoutInt)
        }
        if let privacyStatusString = configSharedState[CampaignClassicConstants.EventDataKeys.Configuration.GLOBAL_CONFIG_PRIVACY] as? String {
            privacyStatus = PrivacyStatus(rawValue: privacyStatusString)!
        }
    }
}
