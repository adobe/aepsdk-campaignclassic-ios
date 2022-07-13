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

class CampaignClassicState {
    private let LOG_TAG = "CampaignClassicState"
    private(set) var dataStore: NamedCollectionDataStore

    // Privacy status
    private(set) var privacyStatus: PrivacyStatus = .unknown

    /// Creates a new `CampaignState`.
    init() {
        self.dataStore = NamedCollectionDataStore(name: CampaignClassicConstants.DATASTORE_NAME)
    }

    /// Takes the shared states map and updates the data within the Campaign Classic State.
    /// - Parameter dataMap: The map containing the shared state data required by the Campaign Extension.
    func update(dataMap: [String: [String: Any]?]) {
        for key in dataMap.keys {
            guard let sharedState = dataMap[key] else {
                continue

            }
            switch key {
            case CampaignClassicConstants.EventDataKeys.Configuration.SHARED_STATE_NAME:
                extractConfigurationInfo(from: sharedState ?? [:])
            default:
                break
            }

        }
    }

    /// Extracts the configuration data from the provided shared state data.
    /// - Parameter configurationData the data map from the `Configuration` shared state.
    private func extractConfigurationInfo(from configurationData: [String: Any]) {
        self.privacyStatus = PrivacyStatus.init(rawValue: configurationData[CampaignClassicConstants.EventDataKeys.Configuration.GLOBAL_CONFIG_PRIVACY] as? PrivacyStatus.RawValue ?? PrivacyStatus.unknown.rawValue) ?? .unknown
    }
}
