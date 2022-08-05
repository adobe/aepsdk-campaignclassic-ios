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
import AEPServices
import XCTest

class CampaignClassicPublicAPITests: XCTestCase {
    
    let SAMPLE_PUSHTOKEN_DATA = "PushToken".data(using: .utf8)!
    let SAMPLE_PUSHTOKEN_AS_HEXSTRING = "50757368546F6B656E"
    let SAMPLE_INFO : [String : String] = ["key" : "value"]
    

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
        let SAMPLE_ADDITIONAL_DATA = ["string" : "abc", "number" : 4, "boolean" : true] as [String : Any]
        let ANYCODABLE_ADDITIONAL_DATA = AnyCodable.from(dictionary: SAMPLE_ADDITIONAL_DATA)
        
        // event dispatch verification
        EventHub.shared.getExtensionContainer(MockExtension.self)?.registerListener(type: EventType.campaign,
                                                                                    source: EventSource.requestContent) { event in
            // unwrap optionals
            let isRegisterDeviceEvent = try? XCTUnwrap(event.data?[CampaignClassicConstants.EventDataKeys.CampaignClassic.REGISTER_DEVICE] as? Bool)
            let deviceToken = try? XCTUnwrap(event.data?[CampaignClassicConstants.EventDataKeys.CampaignClassic.DEVICE_TOKEN] as? String)
            let userKey = try? XCTUnwrap(event.data?[CampaignClassicConstants.EventDataKeys.CampaignClassic.USER_KEY] as? String)
            let additionalParameters = try? XCTUnwrap(event.data?[CampaignClassicConstants.EventDataKeys.CampaignClassic.ADDITIONAL_PARAMETERS] as? [String : AnyCodable])
            
            // verify
            XCTAssertEqual(isRegisterDeviceEvent, true)
            XCTAssertEqual(deviceToken, self.SAMPLE_PUSHTOKEN_AS_HEXSTRING)
            XCTAssertEqual(userKey, SAMPLE_USER_KEY)
            XCTAssertEqual(additionalParameters, ANYCODABLE_ADDITIONAL_DATA)
            
            // verify deviceInfo
            let deviceInfo = try? XCTUnwrap(event.data?[CampaignClassicConstants.EventDataKeys.CampaignClassic.DEVICE_INFO] as? [String : String])
            XCTAssertNotNil(deviceInfo?[CampaignClassicConstants.EventDataKeys.CampaignClassic.DEVICE_INFO_KEY_DEVICE_MODEL])
            XCTAssertEqual("iOS",deviceInfo?[CampaignClassicConstants.EventDataKeys.CampaignClassic.DEVICE_INFO_KEY_OS_NAME])
            XCTAssertEqual("iPhone",deviceInfo?[CampaignClassicConstants.EventDataKeys.CampaignClassic.DEVICE_INFO_KEY_DEVICE_MODEL])
            
            expectation.fulfill()
        }
        
        // test
        CampaignClassic.registerDevice(token: SAMPLE_PUSHTOKEN_DATA, userKey: SAMPLE_USER_KEY, additionalParameters: SAMPLE_ADDITIONAL_DATA)
        
        // verify
        wait(for: [expectation], timeout: 1)
    }
    
    
    func test_trackNotificationClick() throws {
        let expectation = XCTestExpectation(description: "CampaignClassic Track Notification Click should dispatch appropriate event")
        
        // event dispatch verification
        EventHub.shared.getExtensionContainer(MockExtension.self)?.registerListener(type: EventType.campaign,
                                                                                    source: EventSource.requestContent) { event in
            // unwrap optionals
            let isTrackClickEvent = try? XCTUnwrap(event.data?[CampaignClassicConstants.EventDataKeys.CampaignClassic.TRACK_CLICK] as? Bool)
            let trackInfo = try? XCTUnwrap(event.data?[CampaignClassicConstants.EventDataKeys.CampaignClassic.TRACK_INFO] as? [String : String])
            
            // verify
            XCTAssertEqual(isTrackClickEvent, true)
            XCTAssertEqual(trackInfo, self.SAMPLE_INFO)
            
            expectation.fulfill()
        }
        
        CampaignClassic.trackNotificationClick(withUserInfo: SAMPLE_INFO)
        
        // verify
        wait(for: [expectation], timeout: 2)
    }
    
    func test_trackNotificationReceive() throws {
    
        let expectation = XCTestExpectation(description: "CampaignClassic Track Notification Receive should dispatch appropriate event")
        
        // event dispatch verification
        EventHub.shared.getExtensionContainer(MockExtension.self)?.registerListener(type: EventType.campaign,
                                                                                    source: EventSource.requestContent) { event in
            // unwrap optionals
            let isTrackReceiveEvent = try? XCTUnwrap(event.data?[CampaignClassicConstants.EventDataKeys.CampaignClassic.TRACK_RECEIVE] as? Bool)
            let trackInfo = try? XCTUnwrap(event.data?[CampaignClassicConstants.EventDataKeys.CampaignClassic.TRACK_INFO] as? [String : String])
            
            // verify
            XCTAssertEqual(isTrackReceiveEvent, true)
            XCTAssertEqual(trackInfo, self.SAMPLE_INFO)
            
            expectation.fulfill()
        }
        
        CampaignClassic.trackNotificationReceive(withUserInfo: SAMPLE_INFO)
        
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
