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
        if let value = self.value {
            switch value {
            case is String:
                return self.stringValue
            case is Int:
                if let intValue = self.intValue { return String(intValue) }
            case is Double:
                if let doubleValue = self.doubleValue { return String(doubleValue) }
            case is Bool:
                if let boolValue = self.boolValue { return String(boolValue) }
            case is Float:
                if let floatValue = self.floatValue { return String(floatValue) }
            default:
                return nil
            }
        }
        return nil
    }
}
