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

@testable import AEPCampaignClassic
@testable import AEPCore
@testable import AEPLifecycle
@testable import AEPServices
import Foundation
import XCTest

class CampaignClassicFunctionalTests: XCTestCase {
    var mockRuntime: TestableExtensionRuntime!
    var testableNetworkService: TestableNetworkService!
    var datastore: NamedCollectionDataStore!

    override func setUp() {
        UserDefaults.clear()
        FileManager.default.clearCache()
        ServiceProvider.shared.reset()
        EventHub.reset()
        datastore = NamedCollectionDataStore(name: TestConstants.DATASTORE_NAME)
        mockRuntime = TestableExtensionRuntime()
        testableNetworkService = TestableNetworkService()
        ServiceProvider.shared.networkService = testableNetworkService
        mockRuntime.resetDispatchedEventAndCreatedSharedStates()
        sleep(2)
    }

    override func tearDown() {
    }

    func initExtensionsAndWait() {
        let initExpectation = XCTestExpectation(description: "init extensions")
        MobileCore.setLogLevel(.trace)
        MobileCore.registerExtensions([CampaignClassic.self, Lifecycle.self]) {
            initExpectation.fulfill()
        }
        wait(for: [initExpectation], timeout: 2)
    }

    func updateConfiguration(customConfig: [String: Any]? = nil) {
        var configDict = [
            CampaignClassicConstants.EventDataKeys.Configuration.GLOBAL_CONFIG_PRIVACY: PrivacyStatus.optedIn.rawValue
        ] as [String: Any]

        configDict.merge(customConfig ?? [:]) { _, newValue in
            newValue
        }

       MobileCore.updateConfigurationWith(configDict: configDict)
       sleep(1)
    }

}
