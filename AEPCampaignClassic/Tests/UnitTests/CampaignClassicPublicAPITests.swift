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
@testable import AEPCampaignClassic
import XCTest

class CampaignClassicPublicAPITests: XCTestCase {
    
    let SAMPLE_PUSHTOKEN_DATA = "PushToken".data(using: .utf8)!
    let SAMPLE_PUSHTOKEN_AS_HEXSTRING = "50757368546F6B656E"
    let SAMPLE_INFO : [String : String] = ["key" : "value"]
    let SAMPLE_ADDITIONAL_DATA = ["additionalDataKey" : "additionalDataValue"]

    override func setUpWithError() throws {
        EventHub.shared.start()
        registerMockExtension(MockExtension.self)
    }

    override func tearDownWithError() throws {
        unregisterMockExtension(MockExtension.self)
    }

    func test_registerDevice() throws {
        let SAMPLE_USER_KEY = "UserKey"
        let expectation = XCTestExpectation(description: "Register Device API should dispatch appropriate event")
        
        // event dispatch verification
        EventHub.shared.getExtensionContainer(MockExtension.self)?.registerListener(type: CampaignClassicConstants.SDKEventType.CAMPAIGN_CLASSIC,
                                                                                    source: EventSource.requestContent) { event in
            XCTAssertEqual(event.data?[CampaignClassicConstants.EventDataKeys.CampaignClassic.REGISTER_DEVICE] as! Bool, true)
            XCTAssertEqual(event.data?[CampaignClassicConstants.EventDataKeys.CampaignClassic.DEVICE_TOKEN] as! String, self.SAMPLE_PUSHTOKEN_AS_HEXSTRING)
            XCTAssertEqual(event.data?[CampaignClassicConstants.EventDataKeys.CampaignClassic.USER_KEY] as! String, SAMPLE_USER_KEY)
            XCTAssertEqual(event.data?[CampaignClassicConstants.EventDataKeys.CampaignClassic.ADDITIONAL_PARAMETERS] as! [String : String], self.SAMPLE_ADDITIONAL_DATA)
            
            // verify deviceInfo
            let deviceInfo = event.data?[CampaignClassicConstants.EventDataKeys.CampaignClassic.DEVICE_INFO] as! [String : String]
            XCTAssertNotNil(deviceInfo[CampaignClassicConstants.EventDataKeys.CampaignClassic.DEVICE_INFO_KEY_DEVICE_MODEL])
            XCTAssertEqual("iOS",deviceInfo[CampaignClassicConstants.EventDataKeys.CampaignClassic.DEVICE_INFO_KEY_OS_NAME])
            XCTAssertEqual("iPhone",deviceInfo[CampaignClassicConstants.EventDataKeys.CampaignClassic.DEVICE_INFO_KEY_DEVICE_MODEL])
            expectation.fulfill()
        }
        
        CampaignClassic.registerDevice(token: SAMPLE_PUSHTOKEN_DATA, userKey: SAMPLE_USER_KEY, additionalParameter: SAMPLE_ADDITIONAL_DATA, callback: { isCompleted in
            // callback verification will be done in functional test
        })
        
        // verify
        wait(for: [expectation], timeout: 1)
    }
    
    
    func test_trackNotificationClick() throws {
        let expectation = XCTestExpectation(description: "CampaignClassic Track Notification Click should dispatch appropriate event")
        
        // event dispatch verification
        EventHub.shared.getExtensionContainer(MockExtension.self)?.registerListener(type: CampaignClassicConstants.SDKEventType.CAMPAIGN_CLASSIC,
                                                                                    source: EventSource.requestContent) { event in
            XCTAssertEqual(event.data?[CampaignClassicConstants.EventDataKeys.CampaignClassic.TRACK_CLICK] as! Bool, true)
            XCTAssertEqual(event.data?[CampaignClassicConstants.EventDataKeys.CampaignClassic.TRACK_INFO] as! [String : String], self.SAMPLE_INFO)
            expectation.fulfill()
        }
        
        CampaignClassic.trackNotificationClick(trackingInfo: SAMPLE_INFO)
        
        // verify
        wait(for: [expectation], timeout: 2)
    }
    
    func test_trackNotificationReceive() throws {
    
        let expectation = XCTestExpectation(description: "CampaignClassic Track Notification Receive should dispatch appropriate event")
        
        // event dispatch verification
        EventHub.shared.getExtensionContainer(MockExtension.self)?.registerListener(type: CampaignClassicConstants.SDKEventType.CAMPAIGN_CLASSIC,
                                                                                    source: EventSource.requestContent) { event in
            XCTAssertEqual(event.data?[CampaignClassicConstants.EventDataKeys.CampaignClassic.TRACK_RECEIVE] as! Bool, true)
            XCTAssertEqual(event.data?[CampaignClassicConstants.EventDataKeys.CampaignClassic.TRACK_INFO] as! [String : String], self.SAMPLE_INFO)
            expectation.fulfill()
        }
        
        CampaignClassic.trackNotificationReceive(trackingInfo: SAMPLE_INFO)
        
        // verify
        wait(for: [expectation], timeout: 2)
    }
    
    //********************************************************************
    // Private methods
    //********************************************************************

    private func registerMockExtension<T: Extension> (_ type: T.Type) {
        let semaphore = DispatchSemaphore(value: 0)
        EventHub.shared.registerExtension(type) { _ in
            semaphore.signal()
        }

        semaphore.wait()
    }

    private func unregisterMockExtension<T: Extension> (_ type: T.Type) {
        let semaphore = DispatchSemaphore(value: 0)
        EventHub.shared.unregisterExtension(type) { _ in
            semaphore.signal()
        }

        semaphore.wait()
    }
}
