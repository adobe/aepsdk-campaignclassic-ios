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
    var configSharedState : [String : Any]?
    
    init(forEvent event: Event, runtime: ExtensionRuntime) {
        configSharedState = runtime.getSharedState(extensionName: CampaignClassicConstants.EventDataKeys.Configuration.EXTENSION_NAME, event: event, barrier: false)?.value
    }
    
    var marketingServer: String? {
        guard let marketingServer = configSharedState?[CampaignClassicConstants.EventDataKeys.Configuration.CAMPAIGNCLASSIC_MARKETING_SERVER] as? String, !marketingServer.isEmpty else {
            return nil
        }
        return marketingServer
    }
    
    var integrationKey: String? {
        guard let integrationKey = configSharedState?[CampaignClassicConstants.EventDataKeys.Configuration.CAMPAIGNCLASSIC_INTEGRATION_KEY] as? String, !integrationKey.isEmpty else {
            return nil
        }
        return integrationKey
    }
    
    var trackingServer: String? {
        guard let trackingServer = configSharedState?[CampaignClassicConstants.EventDataKeys.Configuration.CAMPAIGNCLASSIC_TRACKING_SERVER] as? String, !trackingServer.isEmpty else {
            return nil
        }
        return trackingServer
    }
    
    var timeout: TimeInterval {
        guard let timeout = configSharedState?[CampaignClassicConstants.EventDataKeys.Configuration.CAMPAIGNCLASSIC_NETWORK_TIMEOUT] as? Int else {
            return CampaignClassicConstants.Default.NETWORK_TIMEOUT
        }
        return TimeInterval(timeout)
    }
    
    var privacyStatus: PrivacyStatus {
        if let privacyStatusString = configSharedState?[CampaignClassicConstants.EventDataKeys.Configuration.GLOBAL_CONFIG_PRIVACY] as? String {
            return PrivacyStatus(rawValue: privacyStatusString)!
        }
        return CampaignClassicConstants.Default.PRIVACY_STATUS
    }
    
}
