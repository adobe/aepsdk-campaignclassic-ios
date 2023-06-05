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


@testable import AEPCore
@testable import AEPServices
import AEPCampaignClassic
import Foundation
import XCTest

class CampaignClassicIntegrationTests: XCTestCase {

    // Configuration test constants
    static let TRACKING_SERVER = "trackserver"
    static let MARKETING_SERVER = "marketingServer"
    static let INTEGRATION_KEY = "integrationKey"
    static let NETWORK_TIMEOUT = 10

    // broadLogID and deliveryID test constants
    let V8_BROADLOG_ID = UUID().uuidString
    let V7_BROADLOG_ID = "55336"
    let DELIVERY_ID = "deliveryId"
    let V7_BROADLOG_ID_HEX = "d828"

    static let V8_BROADLOG_ID = UUID().uuidString
    var mockNetwork: MockNetworking!
    var datastore: NamedCollectionDataStore!
    var capturedRegistrationEvents = [Event]()
    var semaphore = DispatchSemaphore(value: 0)

    override func setUp() {
        continueAfterFailure = false
        UserDefaults.clear()
        ServiceProvider.shared.reset()
        EventHub.reset()
        datastore = NamedCollectionDataStore(name: TestConstants.EXTENSION_NAME)
        mockNetwork = MockNetworking()
        ServiceProvider.shared.networkService = mockNetwork
        MobileCore.registerEventListener(type: EventType.campaign, source: EventSource.responseContent, listener: registrationEventListener(_:))
        sleep(2)
    }

    private func registrationEventListener(_ event: Event) {
        capturedRegistrationEvents.append(event)
        semaphore.signal()
    }


    override func tearDown() {
        capturedRegistrationEvents.removeAll()
        semaphore = DispatchSemaphore(value: 0)
    }

    //*******************************************************************
    // RegisterDevice API
    //*******************************************************************

    func test_registerDevice_happy() {
        // setup
        initExtensionsAndWait()
        setConfiguration()
        let expectedURL = "https://marketingServer/nms/mobile/1/registerIOS.jssp"
        mockNetwork.expectedResponse = HttpConnection(data: nil, response: HTTPURLResponse(url: URL(string: expectedURL)!, statusCode: 200, httpVersion: nil, headerFields: nil), error: nil)

        // test
        CampaignClassic.registerDevice(token: "pushToken".data(using: .utf8)! , userKey: "userkey", additionalParameters: ["email" : "email@email.com" , "userPoints" : 3233])

        // verify network call
        wait(for: [mockNetwork.connectAsyncCalled], timeout: 1)
        XCTAssertEqual(1, mockNetwork.cachedNetworkRequests.count)
        XCTAssertEqual(expectedURL, mockNetwork.cachedNetworkRequests[0].url.absoluteString)

        // verify network request header
        XCTAssertEqual("application/x-www-form-urlencoded;charset=UTF-8", mockNetwork.cachedNetworkRequests[0].httpHeaders["Content-Type"])

        // verify network payload
        let payload = mockNetwork.cachedNetworkRequests[0].payloadAsString()
        XCTAssertTrue(payload.contains("registrationToken=70757368546f6b656e"))
        XCTAssertTrue(payload.contains("mobileAppUuid=integrationKey&"))
        XCTAssertTrue(payload.contains("userKey=userkey&"))
        XCTAssertTrue(payload.contains("deviceName=\(URLEncoder.encode(value: UIDevice.current.name))&"))
        XCTAssertTrue(payload.contains("deviceModel=iPhone&"))
        XCTAssertTrue(payload.contains("deviceBrand=Apple&"))
        XCTAssertTrue(payload.contains("deviceManufacturer=Apple&"))
        XCTAssertTrue(payload.contains("osName=iOS&"))
        XCTAssertTrue(payload.contains("osVersion=\(URLEncoder.encode(value: "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"))&"))
        XCTAssertTrue(payload.contains("osLanguage=en-US&"))
        XCTAssertTrue(payload.contains("additionalParams=%3CadditionalParams%3E%3Cparam%20name%3D%22email%22%20value%3D%22email%40email.com%22%20%2F%3E%3Cparam%20name%3D%22userPoints%22%20value%3D%223233%22%20%2F%3E%3C%2FadditionalParams%3E"))

        // verify persisted registered data hash
        // following is the constant hash generated for the given pushToken, userKey and additional data
        XCTAssertEqual("a40276d0637e4e22d9b41fbe24437e2f5c642c38653b57131cbb3660bfcb745f" , datastore.getString(key: TestConstants.DatastoreKeys.TOKEN_HASH))
        // verify registration status event dispatched with status true
        if semaphore.wait(timeout: .now() + 5) == .timedOut {
            XCTFail("timed out waiting for registration status event")
        }
        XCTAssertFalse(capturedRegistrationEvents.isEmpty)
        XCTAssertEqual(1, capturedRegistrationEvents.count)
        let eventData = capturedRegistrationEvents[0].data
        XCTAssertEqual(true, eventData?["registrationstatus"] as? Bool)

    }

    func test_registerDevice_noUserKeyAndAdditionalParameter() {
        // setup
        initExtensionsAndWait()
        setConfiguration()
        let expectedURL = "https://marketingServer/nms/mobile/1/registerIOS.jssp"
        mockNetwork.expectedResponse = HttpConnection(data: nil, response: HTTPURLResponse(url: URL(string: expectedURL)!, statusCode: 200, httpVersion: nil, headerFields: nil), error: nil)

        // test
        CampaignClassic.registerDevice(token: "pushToken".data(using: .utf8)! , userKey: nil, additionalParameters: nil)

        // verify network call
        wait(for: [mockNetwork.connectAsyncCalled], timeout: 1)
        XCTAssertEqual(1, mockNetwork.cachedNetworkRequests.count)
        XCTAssertEqual(expectedURL, mockNetwork.cachedNetworkRequests[0].url.absoluteString)

        // verify network payload
        let payload = mockNetwork.cachedNetworkRequests[0].payloadAsString()
        XCTAssertTrue(payload.contains("registrationToken=70757368546f6b656e"))
        XCTAssertTrue(payload.contains("userKey=&"))
        XCTAssertTrue(payload.contains("additionalParams%3E%3C%2FadditionalParams%3E"))

        // verify persisted registered data hash
        // following is the constant hash generated for the given pushToken, userKey and additional data
        XCTAssertEqual("08d813a01055453f331f330931661452b23e14148b43efa757e815dede4bf09d" , datastore.getString(key: TestConstants.DatastoreKeys.TOKEN_HASH))
        // verify registration status event dispatched with status true
        if semaphore.wait(timeout: .now() + 5) == .timedOut {
            XCTFail("timed out waiting for registration status event")
        }
        XCTAssertFalse(capturedRegistrationEvents.isEmpty)
        XCTAssertEqual(1, capturedRegistrationEvents.count)
        let eventData = capturedRegistrationEvents[0].data
        XCTAssertEqual(true, eventData?["registrationstatus"] as? Bool)

    }

    func test_registerDevice_verifyFailedDeviceRegistrationWhenMarketingServerReturns404Error() {
        // setup
        initExtensionsAndWait()
        setConfiguration()
        let expectedURL = "https://marketingServer/nms/mobile/1/registerIOS.jssp"
        mockNetwork.expectedResponse = HttpConnection(data: nil, response: HTTPURLResponse(url: URL(string: expectedURL)!, statusCode: 404, httpVersion: nil, headerFields: nil), error: nil)

        // test
        CampaignClassic.registerDevice(token: "pushToken".data(using: .utf8)! , userKey: "userkey", additionalParameters: ["email" : "email@email.com" , "userPoints" : 3233])

        // verify network call
        wait(for: [mockNetwork.connectAsyncCalled], timeout: 1)
        XCTAssertEqual(1, mockNetwork.cachedNetworkRequests.count)
        XCTAssertEqual(expectedURL, mockNetwork.cachedNetworkRequests[0].url.absoluteString)

        // verify network request header
        XCTAssertEqual("application/x-www-form-urlencoded;charset=UTF-8", mockNetwork.cachedNetworkRequests[0].httpHeaders["Content-Type"])

        // verify network payload
        let payload = mockNetwork.cachedNetworkRequests[0].payloadAsString()
        XCTAssertTrue(payload.contains("registrationToken=70757368546f6b656e"))
        XCTAssertTrue(payload.contains("mobileAppUuid=integrationKey&"))
        XCTAssertTrue(payload.contains("userKey=userkey&"))
        XCTAssertTrue(payload.contains("deviceName=\(URLEncoder.encode(value: UIDevice.current.name))&"))
        XCTAssertTrue(payload.contains("deviceModel=iPhone&"))
        XCTAssertTrue(payload.contains("deviceBrand=Apple&"))
        XCTAssertTrue(payload.contains("deviceManufacturer=Apple&"))
        XCTAssertTrue(payload.contains("osName=iOS&"))
        XCTAssertTrue(payload.contains("osVersion=\(URLEncoder.encode(value: "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"))&"))
        XCTAssertTrue(payload.contains("osLanguage=en-US&"))
        XCTAssertTrue(payload.contains("additionalParams=%3CadditionalParams%3E%3Cparam%20name%3D%22email%22%20value%3D%22email%40email.com%22%20%2F%3E%3Cparam%20name%3D%22userPoints%22%20value%3D%223233%22%20%2F%3E%3C%2FadditionalParams%3E"))

        // verify no persisted registered data hash
        XCTAssertEqual(nil , datastore.getString(key: TestConstants.DatastoreKeys.TOKEN_HASH))
        // verify registration status event dispatched with status false
        if semaphore.wait(timeout: .now() + 5) == .timedOut {
            XCTFail("timed out waiting for registration status event")
        }
        XCTAssertFalse(capturedRegistrationEvents.isEmpty)
        XCTAssertEqual(1, capturedRegistrationEvents.count)
        let eventData = capturedRegistrationEvents[0].data
        XCTAssertEqual(false, eventData?["registrationstatus"] as? Bool)
    }

    func test_registerDevice_whenPrivacyOptedOut() {
        // setup
        initExtensionsAndWait()
        setConfiguration(privacyStatus: "optedout")

        // test
        CampaignClassic.registerDevice(token: "pushToken".data(using: .utf8)! , userKey: "userkey", additionalParameters: nil)

        // verify no network call
        verifyNoNetworkCall()
        XCTAssertNil(datastore.getString(key: TestConstants.DatastoreKeys.TOKEN_HASH))
        // verify registration status event dispatched with status false
        if semaphore.wait(timeout: .now() + 5) == .timedOut {
            XCTFail("timed out waiting for registration status event")
        }
        XCTAssertFalse(capturedRegistrationEvents.isEmpty)
        XCTAssertEqual(1, capturedRegistrationEvents.count)
        let eventData = capturedRegistrationEvents[0].data
        XCTAssertEqual(false, eventData?["registrationstatus"] as? Bool)
    }

    func test_registerDevice_whenPrivacyUnknown() {
        // setup
        initExtensionsAndWait()
        setConfiguration(privacyStatus: "optunknown")

        // test
        CampaignClassic.registerDevice(token: "pushToken".data(using: .utf8)! , userKey: "userkey", additionalParameters: nil)

        // verify no network call
        verifyNoNetworkCall()
        XCTAssertNil(datastore.getString(key: TestConstants.DatastoreKeys.TOKEN_HASH))
        // verify registration status event dispatched with status false
        if semaphore.wait(timeout: .now() + 5) == .timedOut {
            XCTFail("timed out waiting for registration status event")
        }
        XCTAssertFalse(capturedRegistrationEvents.isEmpty)
        XCTAssertEqual(1, capturedRegistrationEvents.count)
        let eventData = capturedRegistrationEvents[0].data
        XCTAssertEqual(false, eventData?["registrationstatus"] as? Bool)
    }

    func test_registerDevice_whenNoMarketingServer() {
        // setup
        initExtensionsAndWait()
        setConfiguration(marketingServer: nil)

        // test
        CampaignClassic.registerDevice(token: "pushToken".data(using: .utf8)! , userKey: "userkey", additionalParameters: nil)

        // verify no network call
        verifyNoNetworkCall()
        XCTAssertNil(datastore.getString(key: TestConstants.DatastoreKeys.TOKEN_HASH))
        // verify registration status event dispatched with status false
        if semaphore.wait(timeout: .now() + 5) == .timedOut {
            XCTFail("timed out waiting for registration status event")
        }
        XCTAssertFalse(capturedRegistrationEvents.isEmpty)
        XCTAssertEqual(1, capturedRegistrationEvents.count)
        let eventData = capturedRegistrationEvents[0].data
        XCTAssertEqual(false, eventData?["registrationstatus"] as? Bool)
    }

    func test_registerDevice_whenNoIntegrationKey() {
        // setup
        initExtensionsAndWait()
        setConfiguration(integrationKey: nil)

        // test
        CampaignClassic.registerDevice(token: "pushToken".data(using: .utf8)! , userKey: "userkey", additionalParameters: nil)

        // verify no network call
        verifyNoNetworkCall()
        XCTAssertNil(datastore.getString(key: TestConstants.DatastoreKeys.TOKEN_HASH))
        // verify registration status event dispatched with status false
        if semaphore.wait(timeout: .now() + 5) == .timedOut {
            XCTFail("timed out waiting for registration status event")
        }
        XCTAssertFalse(capturedRegistrationEvents.isEmpty)
        XCTAssertEqual(1, capturedRegistrationEvents.count)
        let eventData = capturedRegistrationEvents[0].data
        XCTAssertEqual(false, eventData?["registrationstatus"] as? Bool)
    }

    func test_registerDevice_whenNoConfiguration() {
        // setup
        initExtensionsAndWait()

        // test
        CampaignClassic.registerDevice(token: "pushToken".data(using: .utf8)! , userKey: "userkey", additionalParameters: nil)

        // verify no network call
        verifyNoNetworkCall()
        XCTAssertNil(datastore.getString(key: TestConstants.DatastoreKeys.TOKEN_HASH))
        // verify no registration status event dispatched
        sleep(2)
        XCTAssertTrue(capturedRegistrationEvents.isEmpty)
        XCTAssertEqual(0, capturedRegistrationEvents.count)
    }

    func test_registerDevice_whenMultipleRegisterCallsWithSameData() {
        // setup
        initExtensionsAndWait()
        setConfiguration()
        let expectedURL = "https://marketingServer/nms/mobile/1/registerIOS.jssp"
        mockNetwork.expectedResponse = HttpConnection(data: nil, response: HTTPURLResponse(url: URL(string: expectedURL)!, statusCode: 200, httpVersion: nil, headerFields: nil), error: nil)

        // test
        CampaignClassic.registerDevice(token: "pushToken".data(using: .utf8)! , userKey: "userkey", additionalParameters: ["email" : "email@email.com" , "userPoints" : 3233])

        // verify network call is made
        wait(for: [mockNetwork.connectAsyncCalled], timeout: 1)
        XCTAssertEqual(1, mockNetwork.cachedNetworkRequests.count)
        XCTAssertEqual("a40276d0637e4e22d9b41fbe24437e2f5c642c38653b57131cbb3660bfcb745f" , datastore.getString(key: TestConstants.DatastoreKeys.TOKEN_HASH))
        // verify registration status event dispatched with status true
        if semaphore.wait(timeout: .now() + 5) == .timedOut {
            XCTFail("timed out waiting for registration status event")
        }
        XCTAssertFalse(capturedRegistrationEvents.isEmpty)
        XCTAssertEqual(1, capturedRegistrationEvents.count)
        var eventData = capturedRegistrationEvents[0].data
        XCTAssertEqual(true, eventData?["registrationstatus"] as? Bool)

        // reset
        semaphore = DispatchSemaphore(value: 0)
        capturedRegistrationEvents.removeAll()
        mockNetwork.reset()

        // test
        CampaignClassic.registerDevice(token: "pushToken".data(using: .utf8)! , userKey: "userkey", additionalParameters: ["email" : "email@email.com" , "userPoints" : 3233])

        // verify
        verifyNoNetworkCall()
        // verify registration status event dispatched with status true as previous registration with same data was successful
        if semaphore.wait(timeout: .now() + 5) == .timedOut {
            XCTFail("timed out waiting for registration status event")
        }
        XCTAssertFalse(capturedRegistrationEvents.isEmpty)
        XCTAssertEqual(1, capturedRegistrationEvents.count)
        eventData = capturedRegistrationEvents[0].data
        XCTAssertEqual(true, eventData?["registrationstatus"] as? Bool)
    }

    func test_registerDevice_whenMultipleRegisterCallsWithDifferentData() {
        // setup
        initExtensionsAndWait()
        setConfiguration()
        let expectedURL = "https://marketingServer/nms/mobile/1/registerIOS.jssp"
        mockNetwork.expectedResponse = HttpConnection(data: nil, response: HTTPURLResponse(url: URL(string: expectedURL)!, statusCode: 200, httpVersion: nil, headerFields: nil), error: nil)

        // test
        CampaignClassic.registerDevice(token: "pushToken".data(using: .utf8)! , userKey: "userkey", additionalParameters: ["email" : "email@email.com" , "userPoints" : 3233])

        // verify
        wait(for: [mockNetwork.connectAsyncCalled], timeout: 5)
        XCTAssertEqual(1, mockNetwork.cachedNetworkRequests.count)
        XCTAssertEqual("a40276d0637e4e22d9b41fbe24437e2f5c642c38653b57131cbb3660bfcb745f" , datastore.getString(key: TestConstants.DatastoreKeys.TOKEN_HASH))
        // verify registration status event dispatched with status true
        if semaphore.wait(timeout: .now() + 5) == .timedOut {
            XCTFail("timed out waiting for registration status event")
        }
        XCTAssertFalse(capturedRegistrationEvents.isEmpty)
        XCTAssertEqual(1, capturedRegistrationEvents.count)
        var eventData = capturedRegistrationEvents[0].data
        XCTAssertEqual(true, eventData?["registrationstatus"] as? Bool)
        capturedRegistrationEvents.removeAll()
        semaphore = DispatchSemaphore(value: 0)

        // reset
        semaphore = DispatchSemaphore(value: 0)
        capturedRegistrationEvents.removeAll()
        mockNetwork.reset()

        // test again
        CampaignClassic.registerDevice(token: "pushToken".data(using: .utf8)! , userKey: "userkey", additionalParameters:nil)

        // verify registration call is made again
        wait(for: [mockNetwork.connectAsyncCalled], timeout: 1)
        XCTAssertEqual(1, mockNetwork.cachedNetworkRequests.count)
        // verify that the registration data is changed
        XCTAssertEqual("6c78a6175d527e5d620285b86f718cfd524c0a26e65c4a8db5a0f8aa5b67e4f1" , datastore.getString(key: TestConstants.DatastoreKeys.TOKEN_HASH))
        // verify registration status event dispatched with status true
        if semaphore.wait(timeout: .now() + 5) == .timedOut {
            XCTFail("timed out waiting for registration status event")
        }
        XCTAssertFalse(capturedRegistrationEvents.isEmpty)
        XCTAssertEqual(1, capturedRegistrationEvents.count)
        eventData = capturedRegistrationEvents[0].data
        XCTAssertEqual(true, eventData?["registrationstatus"] as? Bool)
    }


    //*******************************************************************
    // Tracking API
    //*******************************************************************
    func test_trackNotificationReceive_happy() {
        // setup
        initExtensionsAndWait()
        setConfiguration()
        let expectedURL = "https://trackserver/r/?id=h\(V8_BROADLOG_ID),deliveryId,1"
        mockNetwork.expectedResponse = HttpConnection(data: nil, response: HTTPURLResponse(url: URL(string: expectedURL)!, statusCode: 200, httpVersion: nil, headerFields: nil), error: nil)

        // test
        CampaignClassic.trackNotificationReceive(withUserInfo: ["_mId" : V8_BROADLOG_ID, "_dId" : DELIVERY_ID])

        // verify
        wait(for: [mockNetwork.connectAsyncCalled], timeout: 1)
        XCTAssertEqual(1, mockNetwork.cachedNetworkRequests.count)
        XCTAssertEqual(expectedURL, mockNetwork.cachedNetworkRequests[0].url.absoluteString)
    }

    func test_trackNotificationClick_happy() {
        // setup
        initExtensionsAndWait()
        setConfiguration()
        let expectedURL = "https://trackserver/r/?id=h\(V8_BROADLOG_ID),deliveryId,2"
        mockNetwork.expectedResponse = HttpConnection(data: nil, response: HTTPURLResponse(url: URL(string: expectedURL)!, statusCode: 200, httpVersion: nil, headerFields: nil), error: nil)


        // test
        CampaignClassic.trackNotificationClick(withUserInfo: ["_mId" : V8_BROADLOG_ID, "_dId" : DELIVERY_ID])

        // verify
        wait(for: [mockNetwork.connectAsyncCalled], timeout: 1)
        XCTAssertEqual(1, mockNetwork.cachedNetworkRequests.count)
        XCTAssertEqual(expectedURL, mockNetwork.cachedNetworkRequests[0].url.absoluteString)
    }

    func test_trackNotification_withV7BroadlogId() {
        // setup
        initExtensionsAndWait()
        setConfiguration()
        let expectedURL = "https://trackserver/r/?id=h\(V7_BROADLOG_ID_HEX),deliveryId,2"
        mockNetwork.expectedResponse = HttpConnection(data: nil, response: HTTPURLResponse(url: URL(string: expectedURL)!, statusCode: 200, httpVersion: nil, headerFields: nil), error: nil)


        // test
        CampaignClassic.trackNotificationClick(withUserInfo: ["_mId" : V7_BROADLOG_ID, "_dId" : DELIVERY_ID])

        // verify
        wait(for: [mockNetwork.connectAsyncCalled], timeout: 1)
        XCTAssertEqual(1, mockNetwork.cachedNetworkRequests.count)
        XCTAssertEqual(expectedURL, mockNetwork.cachedNetworkRequests[0].url.absoluteString)
    }

    func test_trackNotification_NoTrackingServer() {
        // setup
        initExtensionsAndWait()
        setConfiguration(trackingServer: nil)

        // test
        CampaignClassic.trackNotificationClick(withUserInfo: ["_mId" : V8_BROADLOG_ID, "_dId" : DELIVERY_ID])

        // verify
        verifyNoNetworkCall()
    }

    func test_trackNotification_NoConfiguration() {
        // setup
        initExtensionsAndWait()

        // test
        CampaignClassic.trackNotificationClick(withUserInfo: ["_mId" : V8_BROADLOG_ID, "_dId" : DELIVERY_ID])

        // verify
        verifyNoNetworkCall()
    }

    func test_trackNotification_NoBroadLogID() {
        // setup
        initExtensionsAndWait()
        setConfiguration(trackingServer: nil)

        // test
        CampaignClassic.trackNotificationClick(withUserInfo: ["_dId" : DELIVERY_ID])

        // verify
        verifyNoNetworkCall()
    }

    func test_trackNotification_NoDeliveryID() {
        // setup
        initExtensionsAndWait()
        setConfiguration(trackingServer: nil)

        // test
        CampaignClassic.trackNotificationClick(withUserInfo: ["_mId" : V8_BROADLOG_ID])

        // verify
        verifyNoNetworkCall()
    }

    func test_trackNotification_whenPrivacyOptOut() {
        // setup
        initExtensionsAndWait()
        setConfiguration(privacyStatus: "optedout")

        // test
        CampaignClassic.trackNotificationClick(withUserInfo: ["_mId" : V8_BROADLOG_ID])

        // verify
        verifyNoNetworkCall()
    }

    func test_trackNotification_whenPrivacyUnknown() {
        // setup
        initExtensionsAndWait()
        setConfiguration(privacyStatus: "optunknown")

        // test
        CampaignClassic.trackNotificationClick(withUserInfo: ["_mId" : V8_BROADLOG_ID])

        // verify
        verifyNoNetworkCall()
    }

    func test_trackNotification_multipleTrackCalls() {
        // setup
        initExtensionsAndWait()
        setConfiguration()
        mockNetwork.connectAsyncCalled.expectedFulfillmentCount = 2

        // test
        CampaignClassic.trackNotificationReceive(withUserInfo: ["_mId" : V8_BROADLOG_ID, "_dId" : DELIVERY_ID])
        CampaignClassic.trackNotificationClick(withUserInfo: ["_mId" : V8_BROADLOG_ID, "_dId" : DELIVERY_ID])

        // verify
        wait(for: [mockNetwork.connectAsyncCalled], timeout: 1)
        XCTAssertEqual(2, mockNetwork.cachedNetworkRequests.count)
    }


    //*******************************************************************
    // private verifiers
    //*******************************************************************
    func verifyNoNetworkCall() {
        mockNetwork.connectAsyncCalled.isInverted = true
        wait(for: [mockNetwork.connectAsyncCalled], timeout: 2)
        XCTAssertEqual(0, mockNetwork.cachedNetworkRequests.count)
    }

    //*******************************************************************
    // private methods
    //*******************************************************************

    private func initExtensionsAndWait() {
        let initExpectation = XCTestExpectation(description: "init extensions")
        MobileCore.setLogLevel(.trace)
        MobileCore.registerExtensions([CampaignClassic.self]) {
            initExpectation.fulfill()
        }
        wait(for: [initExpectation], timeout: 2)
    }

    private func setConfiguration(marketingServer: String? = MARKETING_SERVER,
                                  integrationKey: String? = INTEGRATION_KEY,
                                  trackingServer : String? = TRACKING_SERVER,
                                  privacyStatus : String = PrivacyStatus.optedIn.rawValue,
                                  networkTimeout : Int = NETWORK_TIMEOUT) {
        let config = [ TestConstants.EventDataKeys.Configuration.GLOBAL_CONFIG_PRIVACY: privacyStatus,
                       TestConstants.EventDataKeys.Configuration.CAMPAIGNCLASSIC_TRACKING_SERVER: trackingServer as Any,
                       TestConstants.EventDataKeys.Configuration.CAMPAIGNCLASSIC_MARKETING_SERVER: marketingServer as Any,
                       TestConstants.EventDataKeys.Configuration.CAMPAIGNCLASSIC_INTEGRATION_KEY: integrationKey as Any,
                       TestConstants.EventDataKeys.Configuration.CAMPAIGNCLASSIC_NETWORK_TIMEOUT: networkTimeout]
        MobileCore.updateConfigurationWith(configDict: config)
        sleep(2)
    }

}
