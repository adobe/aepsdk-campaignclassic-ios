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
import XCTest
@testable import AEPCampaignClassic

class StringSHA256: XCTestCase {
    
    func test_SHA256Hashing() throws {
        XCTAssertEqual("".sha256(), "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
        XCTAssertEqual("hello".sha256(), "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824")
        XCTAssertEqual("@@%%&&!!".sha256(), "80e71abeaf61c544800eceb742530c61cc0375cd8e75352aa3b8dddb77149731")
        XCTAssertEqual("a b c".sha256(), "0e9f64031fcb2bc708b531c2a20441580425d151a38503f38592a7dd36019d3b")
    }
    
}
