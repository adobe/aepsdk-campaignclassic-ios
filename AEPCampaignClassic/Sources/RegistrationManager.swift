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

///
/// Manages Campaign Classic device registration requests.
///
class RegistrationManager {

    private var runtime: ExtensionRuntime
    private var systemInfoService: SystemInfoService {
        ServiceProvider.shared.systemInfoService
    }

    /// DataStore instance to access Campaign Classic's stored properties.
    let datastore = NamedCollectionDataStore(name: CampaignClassicConstants.EXTENSION_NAME)

    /// A variable holding the SHA256 hashed device registration information.
    /// The following variable is a hash of deviceToken, userKey and xml serialized additional parameters provided from the user.
    /// This property is set if the device is successfully registered with the campaign servers.
    /// This property is then used to hold back future device registration calls with unchanged data.
    /// The setter and getter of this property will use the datastore to store and retrieve the information.
    private(set) var hashedRegistrationData: String? {
        get {
            datastore.getString(key: CampaignClassicConstants.DatastoreKeys.TOKEN_HASH)
        }
        set {
            guard let newValue = newValue else {
                datastore.remove(key: CampaignClassicConstants.DatastoreKeys.TOKEN_HASH)
                return
            }
            datastore.set(key: CampaignClassicConstants.DatastoreKeys.TOKEN_HASH, value: newValue)
        }
    }

    /// Initializer for CampaignClassicRegistrationManager with extensionRuntime instance.
    /// Extension runtime is used for retrieving the configuration shared state.
    /// - Parameter runtime: the Campaign Classic extension's runtime
    init(_ runtime: ExtensionRuntime) {
        self.runtime = runtime
    }

    /// Clears the stored hashed registration data from memory and persistence.
    func clearRegistrationData() {
        hashedRegistrationData = nil
    }

    /// Sends a device registration request to the configured Campaign Classic server.
    /// If configuration is not available or Campaign Classic marketing server is not configured, no request is sent.
    /// If registration information has not changed since the last request, no request is sent.
    /// If the privacy is opted out , no request is sent.
    /// - Parameter event: the campaign registration request event containing all the device/user details
    func registerDevice(event: Event) {

        // retrieve the device token from the event
        // device token is the unique token received from Apple push notification service through the application
        // bail out from the registration request if device token is unavailable
        guard let deviceToken = event.deviceToken else {
            Log.debug(label: CampaignClassicConstants.LOG_TAG, "Device Registration failed, device token is not available.")
            dispatchRegistrationStatus(registrationStatus: false)
            return
        }

        // bail out if the privacy is not opted In
        let configuration = CampaignClassicConfiguration.init(forEvent: event, runtime: runtime)
        guard configuration.privacyStatus == PrivacyStatus.optedIn else {
            Log.debug(label: CampaignClassicConstants.LOG_TAG, "Device Registration failed, MobilePrivacyStatus is not optedIn.")
            dispatchRegistrationStatus(registrationStatus: false)
            return
        }

        // bail out if the required configuration for device registration request is unavailable
        guard let integrationKey = configuration.integrationKey, let marketingServer = configuration.marketingServer else {
            Log.debug(label: CampaignClassicConstants.LOG_TAG, "Device Registration failed, `campaignclassic.ios.integrationKey` and/or `campaignclassic.marketingServer` configuration keys are unavailable.")
            dispatchRegistrationStatus(registrationStatus: false)
            return
        }

        // retrieve the userKey from the event
        // userKey is a string containing user identifier e.g. email
        let userKey = event.userKey ?? ""
        let additionalParametersXML = event.additionalParameters.serializeToXMLString()
        let hashedData = "\(deviceToken)\(userKey)\(additionalParametersXML)".sha256()

        // bail out, If the registration request data has not changed
        guard registrationInfoChanged(hashedData) else {
            Log.debug(label: CampaignClassicConstants.LOG_TAG, "Device Registration request not sent, there is no change in registration info since last successful request.")
            dispatchRegistrationStatus(registrationStatus: true)
            return
        }

        // build the payload
        var payload = String(format: CampaignClassicConstants.REGISTRATION_PAYLOAD_FORMAT,
                             deviceToken.urlEncoded,
                             integrationKey.urlEncoded,
                             userKey.urlEncoded,
                             UIDevice.current.name.urlEncoded,
                             UIDevice.current.model.urlEncoded,
                             CampaignClassicConstants.REGISTER_PARAM_DEVICE_BRAND_APPLE.urlEncoded,
                             CampaignClassicConstants.REGISTER_PARAM_DEVICE_MANUFACTURER_APPLE.urlEncoded,
                             UIDevice.current.systemName.urlEncoded,
                             systemInfoService.getFormattedOperatingSystem().urlEncoded,
                             systemInfoService.getFormattedLocale().urlEncoded)
        payload.append(additionalParametersXML)

        // build url
        let urlString = String(format: CampaignClassicConstants.REGISTRATION_API_URL_BASE, marketingServer)
        guard let url = URL(string: urlString) else {
            Log.debug(label: CampaignClassicConstants.LOG_TAG, "Device Registration failed, Invalid network request URL : \(urlString)")
            dispatchRegistrationStatus(registrationStatus: false)
            return
        }

        // build headers
        let headers = buildHeaders(payload: payload)

        // create a network request
        let request = NetworkRequest(url: url, httpMethod: .post, connectPayload: payload, httpHeaders: headers, connectTimeout: configuration.timeout, readTimeout: configuration.timeout)

        Log.debug(label: CampaignClassicConstants.LOG_TAG, "Device Registration request initiated with \n URL : \(url.absoluteString) \n Headers: \(headers) \n Payload : \(payload)")

        // make the network request
        ServiceProvider.shared.networkService.connectAsync(networkRequest: request) { connection in
            if connection.responseCode == 200 {
                // retrieve the response message from the body
                let responseMessage = String(data: connection.data ?? Data(), encoding: .utf8) ?? "Unable to read response message."
                Log.debug(label: CampaignClassicConstants.LOG_TAG, "Device Registration success. Saving the hashed registration data. Response message : \(responseMessage)")
                self.hashedRegistrationData = hashedData
                self.dispatchRegistrationStatus(registrationStatus: true)
            } else {
                Log.debug(label: CampaignClassicConstants.LOG_TAG, "Device Registration failed, Network Error. Response Code: \(String(describing: connection.responseCode)) URL : \(url.absoluteString)")
                self.dispatchRegistrationStatus(registrationStatus: false)
            }
        }
    }

    private func dispatchRegistrationStatus(registrationStatus: Bool) {
        let eventData = [CampaignClassicConstants.EventDataKeys.CampaignClassic.REGISTRATION_STATUS: registrationStatus] as [String: Any]
        runtime.dispatch(event: Event(name: CampaignClassicConstants.EventName.DEVICE_REGISTRATION_STATUS,
                                      type: EventType.campaign,
                                      source: EventSource.responseContent,
                                      data: eventData))
    }

    /// Returns the network headers required for device registration request for the given payload
    /// - Parameter payload : the registration request payload
    private func buildHeaders(payload: String) -> [String: String] {
        return [HttpConnectionConstants.Header.HTTP_HEADER_KEY_CONTENT_TYPE: HttpConnectionConstants.Header.HTTP_HEADER_CONTENT_TYPE_WWW_FORM_URLENCODED + ";" + CampaignClassicConstants.HEADER_CONTENT_TYPE_UTF8_CHARSET,
                CampaignClassicConstants.HEADER_KEY_CONTENT_LENGTH: String(payload.count)]
    }

    /// Checks if persisted registration information has changed since last request.
    /// - Parameter hashedData : the current registration request's hashed data
    private func registrationInfoChanged(_ hashedData: String) -> Bool {
        return hashedData != hashedRegistrationData
    }
}
