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

@objc(AEPMobileCampaignClassic)
public class CampaignClassic: NSObject, Extension {
    private let LOG_TAG = "CampaignClassic"
    public var name = CampaignClassicConstants.EXTENSION_NAME
    public var friendlyName = CampaignClassicConstants.FRIENDLY_NAME
    public static var extensionVersion = CampaignClassicConstants.EXTENSION_VERSION
    public var metadata: [String: String]?
    public var runtime: ExtensionRuntime
    var state: CampaignClassicState
    typealias EventDispatcher = (_ eventName: String, _ eventType: String, _ eventSource: String, _ contextData: [String: Any]?) -> Void
    let dispatchQueue: DispatchQueue

    private let dependencies: [String] = [
        CampaignClassicConstants.EventDataKeys.Configuration.SHARED_STATE_NAME
    ]

    /// Initializes the Campaign Classic extension
    public required init?(runtime: ExtensionRuntime) {
        self.runtime = runtime
        dispatchQueue = DispatchQueue(label: "\(CampaignClassicConstants.EXTENSION_NAME).dispatchqueue")
        self.state = CampaignClassicState()
        super.init()
    }

    /// Invoked when the Campaign Classic extension has been registered by the `EventHub`
    public func onRegistered() {
        registerListener(type: EventType.configuration, source: EventSource.responseContent, listener: handleConfigurationEvents)

    }

    /// Invoked when the CampaignClassic extension has been unregistered by the `EventHub`, currently a no-op.
    public func onUnregistered() {}

    /// Called before each `Event` processed by the Campaign Classic extension
    /// - Parameter event: event that will be processed next
    /// - Returns: `true` if Configuration and Identity shared states are available
    public func readyForEvent(_ event: Event) -> Bool {
        return getSharedState(extensionName: CampaignClassicConstants.EventDataKeys.Configuration.SHARED_STATE_NAME, event: event)?.status == .set
    }

    /// Handles `Configuration Response` events
    /// - Parameter event: the Configuration `Event` to be handled
    private func handleConfigurationEvents(event: Event) {
        Log.trace(label: self.LOG_TAG, "An event of type '\(event.type)' has been received.")
        dispatchQueue.async { [weak self] in
            guard let self = self else {return}
            self.updateCampaignState(event: event)
            // update CampaignClassicState
            if self.state.privacyStatus == PrivacyStatus.optedOut {
                // handle opt-out
                return
            }
        }
    }

    /// Updates the `CampaignClassicState` with the shared state of other required extensions
    /// - Parameter event: the `Event`containing the shared state of other required extensions
    private func updateCampaignState(event: Event) {
        var sharedStates = [String: [String: Any]?]()
        for extensionName in dependencies {
            sharedStates[extensionName] = runtime.getSharedState(extensionName: extensionName, event: event, barrier: true)?.value

        }
        state.update(dataMap: sharedStates)
    }
}
