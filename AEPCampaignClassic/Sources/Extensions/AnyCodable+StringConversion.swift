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

extension AnyCodable {

    /// Retrieves string value from AnyCodable
    /// Only String, Double, Bool, Float and Int AnyCodable values are converted to String.
    /// Other types are ignored and nil is returned.
    ///
    /// - Returns : A String value of the `Anycodable` input
    func getString() -> String? {
        guard let value = self.value else {
            return nil
        }

        switch value {
        case let stringValue as String:
            return stringValue
        case let intValue as Int:
            return String(intValue)
        case let longValue as Int64:
            return String(longValue)
        case let floatValue as Float:
            return String(floatValue)
        case let doubleValue as Double:
            return String(doubleValue)
        case let boolValue as Bool:
            return String(boolValue)
        default:
            return nil
        }
    }
}
