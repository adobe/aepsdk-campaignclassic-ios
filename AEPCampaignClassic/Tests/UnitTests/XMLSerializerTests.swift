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
import AEPServices
@testable import AEPCampaignClassic
import XCTest


class XMLSerializerTests: XCTestCase {
    
    func test_serializer() throws {
        // setup
        let additionalData = ["company" : AnyCodable.init(stringLiteral: "xxx.corp"),
                              "isRegistered" : AnyCodable.init(booleanLiteral: true),
                              "serial" : AnyCodable.init(integerLiteral : 12345)]
        
        // test
        let serializedXML = additionalData.serializeToXMLString()
        
        //verify for encoded start tag <additionalParams>
        XCTAssertTrue(serializedXML.contains("%3CadditionalParams%3E"))
        //verify for encoded parameter <param name="company" value="xxx.corp" />
        XCTAssertTrue(serializedXML.contains("%3Cparam%20name%3D%22company%22%20value%3D%22xxx.corp%22%20%2F%3E"))
        //verify for encoded parameter <param name="isRegistered" value="true" />
        XCTAssertTrue(serializedXML.contains("%3Cparam%20name%3D%22isRegistered%22%20value%3D%22true%22%20%2F%3E"))
        //verify for encoded parameter <param name="serial" value="12345" />
        XCTAssertTrue(serializedXML.contains("%3Cparam%20name%3D%22serial%22%20value%3D%2212345%22%20%2F%3E"))
        //verify for encoded end tag </additionalParams>"
        XCTAssertTrue(serializedXML.contains("%3C%2FadditionalParams%3E"))
    }
    
    func test_serializer_when_emptyMap() throws {
        // setup
        let additionalData : [String : AnyCodable] = [:]
        
        // test
        let serializedXML = additionalData.serializeToXMLString()
        
        // verify
        XCTAssertEqual("%3CadditionalParams%3E%3C%2FadditionalParams%3E", serializedXML)
    }
    
    func test_serializer_when_symbolsToEscape() throws {
        // setup
        let additionalData : [String : AnyCodable] = ["greeting": "'h>e&l\"l<o'"]
        
        // test
        let serializedXML = additionalData.serializeToXMLString()
        
        // verify
        XCTAssertEqual("%3CadditionalParams%3E%3Cparam%20name%3D%22greeting%22%20value%3D%22%26%23x27%3Bh%26gt%3Be%26amp%3Bl%26quot%3Bl%26lt%3Bo%26%23x27%3B%22%20%2F%3E%3C%2FadditionalParams%3E", serializedXML)
    }
    
    func test_serializer_when_nilValue() throws {
        // setup
        let additionalData = ["company" : AnyCodable.init(nilLiteral: {}())]
                
        // test
        let serializedXML = additionalData.serializeToXMLString()
        
        // verify
        XCTAssertEqual("%3CadditionalParams%3E%3C%2FadditionalParams%3E", serializedXML)
    }
}


