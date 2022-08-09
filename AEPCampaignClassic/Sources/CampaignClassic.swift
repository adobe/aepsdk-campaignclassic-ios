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
    public let name = CampaignClassicConstants.EXTENSION_NAME
    public let friendlyName = CampaignClassicConstants.FRIENDLY_NAME
    public static let extensionVersion = CampaignClassicConstants.EXTENSION_VERSION
    public var metadata: [String: String]?
    public var runtime: ExtensionRuntime
    let dispatchQueue: DispatchQueue

    private var networkService: Networking {
        return ServiceProvider.shared.networkService
    }

    /// Initializes the Campaign Classic extension
    public required init?(runtime: ExtensionRuntime) {
        self.runtime = runtime
        dispatchQueue = DispatchQueue(label: "\(CampaignClassicConstants.EXTENSION_NAME).dispatchqueue")
        super.init()
    }

    /// Invoked when the Campaign Classic extension has been registered by the `EventHub`
    public func onRegistered() {
        registerListener(type: EventType.configuration, source: EventSource.responseContent, listener: handleConfigurationEvents)
        registerListener(type: EventType.campaign, source: EventSource.requestContent, listener: handleCampaignEvents(event:))
    }

    /// Invoked when the CampaignClassic extension has been unregistered by the `EventHub`, currently a no-op.
    public func onUnregistered() {}

    /// Called before each `Event` processed by the Campaign Classic extension
    /// - Parameter event: event that will be processed next
    /// - Returns: `true` if Configuration shared state is available
    public func readyForEvent(_ event: Event) -> Bool {
        guard let configurationSharedState = getSharedState(extensionName: CampaignClassicConstants.EventDataKeys.Configuration.NAME, event: event) else {
            Log.debug(label: CampaignClassicConstants.LOG_TAG, "Event processing is paused, waiting for valid configuration - '\(event.id.uuidString)'.")
            return false
        }
        return configurationSharedState.status == .set
    }

    /// Handles `Configuration Response` events
    /// - Parameter event: the Configuration `Event` to be handled
    private func handleConfigurationEvents(event: Event) {
        Log.trace(label: CampaignClassicConstants.LOG_TAG, "An event of type '\(event.type)' has been received.")
        dispatchQueue.async { [weak self] in
            // todo handle config update
        }
    }

    /// Handles CampaignClassic's registerDevice, track notification click and track notification receive events.
    /// All the other the campaign events are ignored
    /// - Parameter event: the  Campaign Request content event to be handled
    private func handleCampaignEvents(event: Event) {
        Log.trace(label: CampaignClassicConstants.LOG_TAG, "An event of type '\(event.type)' has been received.")
        dispatchQueue.async { [weak self] in
            guard let self = self else {return}
            if event.isRegisterEvent {
                self.handleRegisterDeviceEvent(event: event)
            } else if event.isTrackClickEvent {
                self.handleTrackEvent(event: event, withTagId: CampaignClassicConstants.TRACK_CLICK_TAGID)
            } else if event.isTrackReceiveEvent {
                self.handleTrackEvent(event: event, withTagId: CampaignClassicConstants.TRACK_RECEIVE_TAGID)
            }
        }
    }

    private func handleRegisterDeviceEvent(event: Event) {
        // todo - coming soon
    }

    /// Sends a track request to the configured Campaign Classic tracking server upon notification receive or click.
    /// If Configuration is not available or Campaign Classic is not configured, no track request shall be sent.
    /// Tracking identifiers messageId(_mId) and deliveryId (_dId), retrieved from the message payload, are
    /// required for track request to be sent.
    ///
    /// - Parameters:
    ///   - event : the incoming track event
    ///   - tagId : an integer string indicating whether it is a notification receive or notification click request
    private func handleTrackEvent(event: Event, withTagId tagId: String) {
        let configuration = CampaignClassicConfiguration.init(forEvent: event, runtime: runtime)

        guard let trackingServer = configuration.trackingServer, !trackingServer.isEmpty else {
            Log.debug(label: CampaignClassicConstants.LOG_TAG, "Unable to process TrackNotification request, Configuration not available.")
            return
        }

        if configuration.privacyStatus != PrivacyStatus.optedIn {
            Log.debug(label: CampaignClassicConstants.LOG_TAG, "Unable to process TrackNotification request, MobilePrivacyStatus is not optedIn.")
            return
        }

        guard let deliveryId = event.deliveryId, !deliveryId.isEmpty else {
            Log.debug(label: CampaignClassicConstants.LOG_TAG, "Unable to process TrackNotification request, trackingInfo deliveryId is nil (missing key `_dId` from tracking Info).")
            return
        }

        guard let broadlogId = event.broadlogId, !broadlogId.isEmpty else {
            Log.debug(label: CampaignClassicConstants.LOG_TAG, "Unable to process TrackNotification request, trackingInfo broadLogId is nil (missing key `_mId` from tracking Info).")
            return
        }

        // V8 messageId is received in UUID format while V7 still comes as an integer(decimal) represented as a string.
        // No transformation is required for the V8 UUID however for V7, message Id is parsed as an integer and converted to hex string.
        guard let transformedBroadlogId = transformBroadLogId(broadlogId) else {
            Log.debug(label: CampaignClassicConstants.LOG_TAG, "TrackingInfo broadLogId is nil (Missing key `_mId` from tracking Info), discarding the campaign classic track event.")
            return
        }

        guard let trackingUrl = URL(string: String(format: CampaignClassicConstants.TRACKING_API_URL_BASE, trackingServer, transformedBroadlogId, deliveryId, tagId)) else {
            return
        }

        let request = NetworkRequest(url: trackingUrl, httpMethod: .get, connectPayload: "", httpHeaders: [:], connectTimeout: configuration.timeout, readTimeout: configuration.timeout)

        networkService.connectAsync(networkRequest: request, completionHandler: { connection in
            if connection.responseCode == 200 {
                Log.debug(label: CampaignClassicConstants.LOG_TAG, "TrackNotification success. URL : \(trackingUrl.absoluteString)")
                return
            }

            Log.debug(label: CampaignClassicConstants.LOG_TAG, "Unable to trackNotification, Network Error. Response Code: \(String(describing: connection.responseCode)) URL : \(trackingUrl.absoluteString)")
        })
    }

    /// Validates and transforms the broadIlogId into the required format
    private func transformBroadLogId(_ broadlogId: String) -> String? {
        /// if this is a valid UUID (v8 messageId format), return the string without modification
        if let _ = UUID(uuidString: broadlogId) {
            return broadlogId
        }

        /// if not a valid UUID and neither in v7 format (Integer), return nil
        let broadLogIdInt = Int(broadlogId)
        guard let broadLogIdInt = broadLogIdInt else {
            return nil
        }

        /// return the hex representation of integer for v7 format messageId
        return String(format: "%02X", broadLogIdInt)
    }

}
