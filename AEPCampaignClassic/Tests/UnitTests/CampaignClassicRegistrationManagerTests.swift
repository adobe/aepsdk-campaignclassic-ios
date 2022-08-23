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

import XCTest
import AEPCore
import AEPServices
@testable import AEPCampaignClassic

final class CampaignClassicRegistrationManagerTests: XCTestCase {
        
    // configuration sample values
    static let MARKETING_SERVER = "marketingServer"
    static let INTEGRATION_KEY = "integrationKey"
    static let NETWORK_TIMEOUT = 10
    
    // sample user inputs
    static let USER_KEY = "userKey"
    static let DEVICE_TOKEN = "deviceToken"
    static let ADDITIONAL_DATA = ["string" : "abc", "number" : 4, "boolean" : true] as [String : Any]
        
    let runtime = TestableExtensionRuntime()
    var registrationManager: RegistrationManager!
    var networking: MockNetworking!
    let datastore = NamedCollectionDataStore(name: CampaignClassicConstants.EXTENSION_NAME)
    let systemInfoService = ServiceProvider.shared.systemInfoService
    
    override func setUp() {
        registrationManager = RegistrationManager(runtime)
        
        // Mock Networking
        networking = MockNetworking()
        ServiceProvider.shared.networkService = networking        
    }
    
    override func tearDown() {
        datastore.remove(key: CampaignClassicConstants.DatastoreKeys.TOKEN_HASH)
    }
    
    //*******************************************************************
    // RegisterDevice Tests
    //*******************************************************************
    
    func test_registerDevice_makesCorrectNetworkRequest() throws {
        // setup
        setConfigState()
        let expectedURL = "https://marketingServer/nms/mobile/1/registerIOS.jssp"

        // test
        registrationManager.registerDevice(event: registerDeviceEvent(additionalParameter: [:]))
        
        // verify network call
        wait(for: [networking.connectAsyncCalled], timeout: 1)
        XCTAssertEqual(networking.cachedNetworkRequests.count, 1)

        // verify url
        let networkRequest = networking.cachedNetworkRequests[0]
        XCTAssertEqual(networkRequest.url.absoluteString, expectedURL)
        
        // verify payload
        let payload = networkRequest.payloadAsString()
        XCTAssertTrue(payload.contains("registrationToken=deviceToken&"))
        XCTAssertTrue(payload.contains("mobileAppUuid=integrationKey&"))
        XCTAssertTrue(payload.contains("userKey=userKey&"))
        XCTAssertTrue(payload.contains("deviceName=\(URLEncoder.encode(value: UIDevice.current.name))&"))
        XCTAssertTrue(payload.contains("deviceModel=iPhone&"))
        XCTAssertTrue(payload.contains("deviceBrand=Apple&"))
        XCTAssertTrue(payload.contains("deviceManufacturer=Apple&"))
        XCTAssertTrue(payload.contains("osName=iOS&"))
        XCTAssertTrue(payload.contains("osVersion=\(URLEncoder.encode(value: "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"))&"))
        XCTAssertTrue(payload.contains("osLanguage=en-US&"))
        XCTAssertTrue(payload.contains("additionalParams=%3CadditionalParams%3E%3C%2FadditionalParams%3E"))
        
        // verify header
        XCTAssertEqual(4, networkRequest.httpHeaders.count)
        XCTAssertEqual("application/x-www-form-urlencoded;charset=UTF-8",networkRequest.httpHeaders["Content-Type"])
        XCTAssertEqual(String(payload.count), networkRequest.httpHeaders["Content-Length"])
    }
    
    func test_registerDevice__when_networkSuccess_storeToken() throws {
        // setup
        setConfigState()
        let expectedURL = "https://marketingServer/nms/mobile/1/registerIOS.jssp"
        networking.expectedResponse = HttpConnection(data: nil, response: HTTPURLResponse(url: URL(string: expectedURL)!, statusCode: 200, httpVersion: nil, headerFields: nil), error: nil)

        // test
        registrationManager.registerDevice(event: registerDeviceEvent())
        
        // verify network call
        wait(for: [networking.connectAsyncCalled], timeout: 1)
        XCTAssertEqual(networking.cachedNetworkRequests.count, 1)

        // verify hashed token is stored
        XCTAssertNotNil(registrationManager.hashedRegistrationData)
    }
    
    func test_registerDevice_when_networkError_doesNotStoreToken() throws {
        // setup
        setConfigState()
        enum error: Error { case genericError}
        networking.expectedResponse = HttpConnection(data: nil, response: nil, error: error.genericError)

        // test
        registrationManager.registerDevice(event: registerDeviceEvent())
        
        // verify network call
        wait(for: [networking.connectAsyncCalled], timeout: 1)
        XCTAssertEqual(networking.cachedNetworkRequests.count, 1)

        // verify hashed token is not stored
        XCTAssertNil(registrationManager.hashedRegistrationData)
    }
    
    func test_registerDevice_when_whenConfigurationNoSet() throws {
        // do not setup configuration
        networking.connectAsyncCalled.isInverted = true
        
        // test
        registrationManager.registerDevice(event: registerDeviceEvent())
        
        // verify network call
        verifyNoNetworkCallAndNoTokenStored()
    }
    
    func test_registerDevice_when_privacyOptedOut() throws {
        // setup
        setConfigState(privacyStatus: PrivacyStatus.optedOut.rawValue)
        networking.connectAsyncCalled.isInverted = true
        
        // test
        registrationManager.registerDevice(event: registerDeviceEvent())
        
        // verify
        verifyNoNetworkCallAndNoTokenStored()
    }
    
    func test_registerDevice_when_nilMarketingServer() throws {
        // setup
        setConfigState(marketingServer: nil)
        networking.connectAsyncCalled.isInverted = true
        
        // test
        registrationManager.registerDevice(event: registerDeviceEvent())
        
        // verify
        verifyNoNetworkCallAndNoTokenStored()
    }
    
    func test_registerDevice_when_invalidMarketingServer() throws {
        // setup
        setConfigState(marketingServer: "{}")
        networking.connectAsyncCalled.isInverted = true
        
        // test
        registrationManager.registerDevice(event: registerDeviceEvent())
        
        // verify
        verifyNoNetworkCallAndNoTokenStored()
    }
    
    func test_registerDevice_when_emptyIntegrationKey() throws {
        // setup
        setConfigState(integrationKey: "")
        networking.connectAsyncCalled.isInverted = true
        
        // test
        registrationManager.registerDevice(event: registerDeviceEvent())
        
        // verify
        verifyNoNetworkCallAndNoTokenStored()
    }
    
    func test_registerDevice_when_noDeviceToken() throws {
        // setup
        setConfigState()
        networking.connectAsyncCalled.isInverted = true
        let event = registerDeviceEvent(deviceToken: nil)
        
        // test
        registrationManager.registerDevice(event: event)
        
        // verify
        verifyNoNetworkCallAndNoTokenStored()
    }
    
    func test_registerDevice_when_emptyUserKey() throws {
        // setup
        setConfigState()
        let registrationEvent = registerDeviceEvent(userKey: "")
        
        // test
        registrationManager.registerDevice(event: registrationEvent)
        
        // verify network call is still made with correct payload
        wait(for: [networking.connectAsyncCalled], timeout: 1)
        XCTAssertEqual(networking.cachedNetworkRequests.count, 1)
        let networkRequest = networking.cachedNetworkRequests[0]
        let payload = networkRequest.payloadAsString()
        XCTAssertTrue(payload.contains("userKey=&"))
    }
    
    func test_registerDevice_when_calledWithSameDetails() throws {
        // setup
        setConfigState()
        let event = registerDeviceEvent()
        let expectedURL = "https://marketingServer/nms/mobile/1/registerIOS.jssp"
        networking.expectedResponse = HttpConnection(data: nil, response: HTTPURLResponse(url: URL(string: expectedURL)!, statusCode: 200, httpVersion: nil, headerFields: nil), error: nil)
        
        // test
        registrationManager.registerDevice(event: event)
        registrationManager.registerDevice(event: event) // register device with the same details
        
        
        // verify network call is made only once
        wait(for: [networking.connectAsyncCalled], timeout: 1)
        XCTAssertEqual(networking.cachedNetworkRequests.count, 1)
    }
                
    //*******************************************************************
    // Datastore Tests
    //*******************************************************************
    
    func test_registrationToken_isReadFromDatastore() throws {
        // test
        let hashedToken = "howdy"
        datastore.set(key: CampaignClassicConstants.DatastoreKeys.TOKEN_HASH, value: hashedToken)
        
        // verify
        XCTAssertEqual(hashedToken, registrationManager.hashedRegistrationData)
    }
    
    //*******************************************************************
    // private methods
    //*******************************************************************
    
    private func verifyNoNetworkCallAndNoTokenStored() {
        wait(for: [networking.connectAsyncCalled], timeout: 0.5)
        XCTAssertEqual(networking.cachedNetworkRequests.count, 0)
        XCTAssertNil(registrationManager.hashedRegistrationData)
    }
    
    private func setConfigState(marketingServer: String? = MARKETING_SERVER,
                                integrationKey: String? = INTEGRATION_KEY,
                                privacyStatus: String = PrivacyStatus.optedIn.rawValue,
                                networkTimeOut: Int = NETWORK_TIMEOUT) {
        let configurationSharedState = [ CampaignClassicConstants.EventDataKeys.Configuration.GLOBAL_CONFIG_PRIVACY: privacyStatus,
                                     CampaignClassicConstants.EventDataKeys.Configuration.CAMPAIGNCLASSIC_MARKETING_SERVER: marketingServer as Any,
                                     CampaignClassicConstants.EventDataKeys.Configuration.CAMPAIGNCLASSIC_INTEGRATION_KEY: integrationKey as Any,
                                     CampaignClassicConstants.EventDataKeys.Configuration.CAMPAIGNCLASSIC_NETWORK_TIMEOUT: networkTimeOut]
        runtime.simulateSharedState(for: CampaignClassicConstants.EventDataKeys.Configuration.EXTENSION_NAME, data: (configurationSharedState, .set))
    }
        
    private func registerDeviceEvent(userKey: String? = USER_KEY,
                                     deviceToken: String? = DEVICE_TOKEN,
                                     additionalParameter: [String: Any]? = ADDITIONAL_DATA) -> Event {
        let anyCodableAdditionalData = AnyCodable.from(dictionary: additionalParameter)
        return Event(name: CampaignClassicConstants.EventName.REGISTER_DEVICE,
                     type: EventType.campaign,
                     source: EventSource.requestContent,
                     data: [CampaignClassicConstants.EventDataKeys.CampaignClassic.REGISTER_DEVICE: true,
                            CampaignClassicConstants.EventDataKeys.CampaignClassic.USER_KEY: userKey as Any,
                            CampaignClassicConstants.EventDataKeys.CampaignClassic.DEVICE_TOKEN: deviceToken as Any,
                            CampaignClassicConstants.EventDataKeys.CampaignClassic.ADDITIONAL_PARAMETERS: anyCodableAdditionalData as Any] as [String: Any])
    }

}
