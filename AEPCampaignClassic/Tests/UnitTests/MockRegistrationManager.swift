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

import Foundation
import AEPCore
import XCTest
@testable import AEPCampaignClassic

class MockRegistrationManager: CampaignClassicRegistrationManager {
    
    public var registerDeviceCalled = XCTestExpectation(description: "MockRegistrationManager - Expectation to call 'registerDevice' method.")
    public var clearRegistrationDataCalled = XCTestExpectation(description: "MockRegistrationManager - Expectation to call 'clearRegistrationData' method")
    
    override init(_ runtime: ExtensionRuntime) {
        super.init(runtime)
    }
    
    override func registerDevice(event: Event) {
        registerDeviceCalled.fulfill()
    }
    
    override func clearRegistrationData() {
        clearRegistrationDataCalled.fulfill()
    }
}
