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

extension Dictionary where Key == String, Value == AnyCodable {

    /// - Returns  : A serialized campaign classic xml formatted string.
    func serializeToXMLString() -> String {
        var xmlString = ""
        for(key, value) in self {
            if let stringValue = value.getString() {
                xmlString.append("<param name=\"\(key.escaped())\" value=\"\(stringValue.escaped())\" />")
            }
        }
        return URLEncoder.encode(value: "<additionalParams>\(xmlString)</additionalParams>")
    }
}
