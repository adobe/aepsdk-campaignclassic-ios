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


@testable import AEPCore
@testable import AEPServices
@testable import AEPCampaignClassic
import Foundation
import XCTest

class CampaignClassicTests: XCTestCase {
    
    // Configuration test constants
    static let TRACKING_SERVER = "trackserver"
    static let MARKETING_SERVER = "marketingServer"
    static let INTEGRATION_KEY = "integrationKey"
    static let NETWORK_TIMEOUT = 10
    
    // broadLogID and deliveryID test constants
    static let v8BROADLOG_ID = UUID().uuidString
    static let v7BROADLOG_ID = "55336"
    static let DELIVERY_ID = "deliveryId"
    let v7BROADLOG_ID_HEX = "D828"
      
    // instance variables
    let runtime = TestableExtensionRuntime()
    var campaignClassic: CampaignClassic!
    var networking: MockNetworking!
    
    var configurationSharedState: [String: Any]!
    
    override func setUp() {
        // Mock Networking
        networking = MockNetworking()
        ServiceProvider.shared.networkService = networking
        
        // Initiate Campaign Classic extension
        campaignClassic = CampaignClassic(runtime: runtime)
        campaignClassic.onRegistered()
    }
    
    //*******************************************************************
    // Test ReadyForEvents
    //**********************-*********************************************
    func test_readyForEvents_whenConfigSet() throws {
        // setup
        setConfigState()
        
        // verify
        XCTAssertTrue(campaignClassic.readyForEvent(trackNotificationClickEvent()))
    }
    
    func test_readyForEvents_whenConfigNotSet() throws {
        // do not setup config
        
        // verify
        XCTAssertFalse(campaignClassic.readyForEvent(trackNotificationClickEvent()))
    }
    
    //*******************************************************************
    // Track Notification Click Tests
    //*******************************************************************
    func test_trackNotificationClick_makesCorrectNetworkRequest() throws {
        // setup
        let expectedURL = "https://trackserver/r/?id=h\(CampaignClassicTests.v8BROADLOG_ID),deliveryId,2"
        setConfigState()
        networking.expectedResponse = HttpConnection(data: nil, response: HTTPURLResponse(url: URL(string: expectedURL)!, statusCode: 200, httpVersion: nil, headerFields: nil), error: nil)

        // test
        runtime.simulateComingEvents(trackNotificationClickEvent())
        
        // verify
        wait(for: [networking.connectAsyncCalled], timeout: 1)
        XCTAssertEqual(networking.cachedNetworkRequests.count, 1)
        XCTAssertEqual(networking.cachedNetworkRequests[0].url.absoluteString, expectedURL)
        XCTAssertEqual(networking.cachedNetworkRequests[0].connectTimeout, TimeInterval(CampaignClassicTests.NETWORK_TIMEOUT))
        XCTAssertTrue(networking.cachedNetworkRequests[0].connectPayload.isEmpty)
    }
    
    func test_trackNotificationClick_whenNetworkError() throws {
        // setup
        enum error: Error {
            case genericError
        }
        setConfigState()
        networking.expectedResponse = HttpConnection(data: nil, response: nil, error: error.genericError)

        // test
        runtime.simulateComingEvents(trackNotificationClickEvent())
        
        // verify
        wait(for: [networking.connectAsyncCalled], timeout: 1)
    }
    
    func test_trackNotificationClick_when_noConfigurationSet() throws {
        // do not setup configuration
        networking.connectAsyncCalled.isInverted = true

        // test
        runtime.simulateComingEvents(trackNotificationClickEvent())
        
        // verify
        Thread.sleep(forTimeInterval: 0.5)
        XCTAssertEqual(networking.cachedNetworkRequests.count, 0)
    }
    
    func test_trackNotificationClick_when_privacyOptedOut() throws {
        // setup
        setConfigState(privacyStatus: PrivacyStatus.optedOut.rawValue)
        networking.connectAsyncCalled.isInverted = true

        // test
        runtime.simulateComingEvents(trackNotificationClickEvent())
        
        // verify
        wait(for: [networking.connectAsyncCalled], timeout: 1)
    }
    
    func test_trackNotificationClick_when_noTrackingServer() throws {
        // setup
        setConfigState(trackingServer: nil)
        networking.connectAsyncCalled.isInverted = true

        // test
        runtime.simulateComingEvents(trackNotificationClickEvent())
        
        // verify
        wait(for: [networking.connectAsyncCalled], timeout: 1)
    }
    
    
    func test_trackNotificationClick_when_emptyTrackingServer() throws {
        // setup
        setConfigState(trackingServer: "")
        networking.connectAsyncCalled.isInverted = true

        // test
        runtime.simulateComingEvents(trackNotificationClickEvent())
        
        // verify
        wait(for: [networking.connectAsyncCalled], timeout: 1)
    }
    
    func test_trackNotificationClick_with_v7BroadLogId() throws {
        // setup
        setConfigState()

        // test
        let event = trackNotificationClickEvent(broadLogID: CampaignClassicTests.v7BROADLOG_ID)
        runtime.simulateComingEvents(event)
        
        // verify
        wait(for: [networking.connectAsyncCalled], timeout: 1)
        XCTAssertEqual(networking.cachedNetworkRequests.count, 1)
        XCTAssertEqual(networking.cachedNetworkRequests[0].url.absoluteString, "https://trackserver/r/?id=h\(v7BROADLOG_ID_HEX),deliveryId,2")
    }
    
    func test_trackNotificationClick_with_InValidBroadLogId() throws {
        // setup
        setConfigState()
        networking.connectAsyncCalled.isInverted = true

        // test
        // a valid braodlogID can either be an UUID or IntegerString
        let event = trackNotificationClickEvent(broadLogID: "invalid")
        runtime.simulateComingEvents(event)
        
        // verify
        wait(for: [networking.connectAsyncCalled], timeout: 1)
    }
    
    func test_trackNotificationClick_with_emptyBroadLogId() throws {
        // setup
        setConfigState()
        networking.connectAsyncCalled.isInverted = true

        // test
        runtime.simulateComingEvents(trackNotificationClickEvent(broadLogID: ""))
        
        // verify
        wait(for: [networking.connectAsyncCalled], timeout: 1)
    }
    
    func test_trackNotificationClick_with_nilDeliveryId() throws {
        // setup
        setConfigState()
        networking.connectAsyncCalled.isInverted = true

        // test
        runtime.simulateComingEvents(trackNotificationClickEvent(deliveryID: nil))
        
        // verify
        wait(for: [networking.connectAsyncCalled], timeout: 1)
    }
    
    
    //*******************************************************************
    // Track Notification Receive Tests
    //*******************************************************************
    
    func test_trackNotificationReceive_makesCorrectNetworkRequest() throws {
        // setup
        let expectedURL = "https://trackserver/r/?id=h\(CampaignClassicTests.v8BROADLOG_ID),deliveryId,1"
        setConfigState()
        networking.expectedResponse = HttpConnection(data: nil, response: HTTPURLResponse(url: URL(string: expectedURL)!, statusCode: 200, httpVersion: nil, headerFields: nil), error: nil)

        // test
        runtime.simulateComingEvents(trackNotificationReceiveEvent())
        
        // verify
        wait(for: [networking.connectAsyncCalled], timeout: 1)
        XCTAssertEqual(networking.cachedNetworkRequests.count, 1)
        XCTAssertEqual(networking.cachedNetworkRequests[0].url.absoluteString, expectedURL)
        XCTAssertEqual(networking.cachedNetworkRequests[0].connectTimeout, TimeInterval(CampaignClassicTests.NETWORK_TIMEOUT))
        XCTAssertTrue(networking.cachedNetworkRequests[0].connectPayload.isEmpty)
    }
    
    
    //*******************************************************************
    // private methods
    //*******************************************************************
    
    private func trackNotificationClickEvent(broadLogID : String? = v8BROADLOG_ID, deliveryID : String? = DELIVERY_ID) -> Event {
        let userInfo = ["_mId" : broadLogID, "_dId" : deliveryID]
        return Event(name: CampaignClassicConstants.EventName.TRACK_NOTIFICATION_CLICK,
                     type: EventType.campaign,
                     source: EventSource.requestContent,
                     data: [CampaignClassicConstants.EventDataKeys.CampaignClassic.TRACK_CLICK: true,
                            CampaignClassicConstants.EventDataKeys.CampaignClassic.TRACK_INFO: userInfo] as [String: Any])
    }
    
    private func trackNotificationReceiveEvent(broadLogID : String = v8BROADLOG_ID, deliveryID : String? = DELIVERY_ID) -> Event {
        let userInfo = ["_mId" : broadLogID, "_dId" : deliveryID]
        return Event(name: CampaignClassicConstants.EventName.TRACK_NOTIFICATION_CLICK,
                     type: EventType.campaign,
                     source: EventSource.requestContent,
                     data: [CampaignClassicConstants.EventDataKeys.CampaignClassic.TRACK_RECEIVE: true,
                            CampaignClassicConstants.EventDataKeys.CampaignClassic.TRACK_INFO: userInfo] as [String: Any])
    }
    
    private func setConfigState(trackingServer : String? = TRACKING_SERVER,
                                marketingServer : String? = MARKETING_SERVER,
                                integrationKey : String? = INTEGRATION_KEY,
                                privacyStatus : String = PrivacyStatus.optedIn.rawValue,
                                networkTimeOut : Int = NETWORK_TIMEOUT) {
        configurationSharedState = [ CampaignClassicConstants.EventDataKeys.Configuration.GLOBAL_CONFIG_PRIVACY: privacyStatus,
                                     CampaignClassicConstants.EventDataKeys.Configuration.CAMPAIGNCLASSIC_TRACKING_SERVER: trackingServer as Any,
                                     CampaignClassicConstants.EventDataKeys.Configuration.CAMPAIGNCLASSIC_MARKETING_SERVER: marketingServer as Any,
                                     CampaignClassicConstants.EventDataKeys.Configuration.CAMPAIGNCLASSIC_INTEGRATION_KEY: integrationKey as Any,
                                     CampaignClassicConstants.EventDataKeys.Configuration.CAMPAIGNCLASSIC_NETWORK_TIMEOUT: networkTimeOut]
        runtime.simulateSharedState(for: CampaignClassicConstants.EventDataKeys.Configuration.NAME, data: (configurationSharedState, .set))
    }
}