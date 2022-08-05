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

extension String {
    
    /// Computes and returns a new string in which certain characters are replaced by escape sequences.
    func escaped() -> String {
        var escapedString = self
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
