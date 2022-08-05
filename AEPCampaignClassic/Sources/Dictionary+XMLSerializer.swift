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
            if let stringValue = getStringFromAnyCodable(anyCodable: value) {
                xmlString.append("<param name=\"\(escapeString(key))\" value=\"\(escapeString(stringValue))\" />")
            }
        }
        return URLEncoder.encode(value: "<additionalParams>\(xmlString)</additionalParams>")
    }

    /// Retrieves string value from AnyCodable
    /// Only String, Double, Bool, Float and Int AnyCodable values are converted to String.
    /// Other types are ignored and nil is returned.
    ///
    /// - Parameter anyCodable: An `AnyCodable`value that needs to be unwrapped
    /// - Returns : A String value of the `Anycodable` input
    private func getStringFromAnyCodable(anyCodable: AnyCodable) -> String? {
        if let value = anyCodable.value {
            switch value {
            case is String:
                return anyCodable.stringValue
            case is Int:
                if let intValue = anyCodable.intValue { return String(intValue) }
            case is Double:
                if let doubleValue = anyCodable.doubleValue { return String(doubleValue) }
            case is Bool:
                if let boolValue = anyCodable.boolValue { return String(boolValue) }
            case is Float:
                if let floatValue = anyCodable.floatValue { return String(floatValue) }
            default:
                return nil
            }
        }
        return nil
    }

    /// Creates escaped string from given input string
    private func escapeString(_ input: String) -> String {
        var escapedString = input
        escapedString = escapedString.replacingOccurrences(of: "\r", with: "")
        escapedString = escapedString.replacingOccurrences(of: "\n", with: "")
        escapedString = escapedString.replacingOccurrences(of: "&", with: "&amp;")
        escapedString = escapedString.replacingOccurrences(of: "\"", with: "&quot;")
        escapedString = escapedString.replacingOccurrences(of: "'", with: "&#x27;")
        escapedString = escapedString.replacingOccurrences(of: ">", with: "&gt;")
        escapedString = escapedString.replacingOccurrences(of: "<", with: "&lt;")
        return escapedString
    }
}
