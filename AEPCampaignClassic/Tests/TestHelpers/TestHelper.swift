/*
 Copyright 2020 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http://www.apache.org/licenses/LICENSE-2.0
 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
 */

@testable import AEPCore
import AEPServices
import XCTest

extension EventHub {
    static func reset() {
        shared = EventHub()
    }
}

extension NamedCollectionDataStore {
    static func clear(appGroup: String? = nil) {
        if let appGroup = appGroup, !appGroup.isEmpty {
            guard let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup)?.appendingPathComponent("com.adobe.aep.datastore", isDirectory: true).path else {
                return
            }
            guard let filePaths = try? FileManager.default.contentsOfDirectory(atPath: directory) else {
                return
            }
            for filePath in filePaths {
                try? FileManager.default.removeItem(atPath: directory + "/" + filePath)
            }
        } else {
            let directory = FileManager.default.urls(for: .libraryDirectory, in: .allDomainsMask)[0].appendingPathComponent("com.adobe.aep.datastore", isDirectory: true).path
            guard let filePaths = try? FileManager.default.contentsOfDirectory(atPath: directory) else {
                return
            }
            for filePath in filePaths {
                try? FileManager.default.removeItem(atPath: directory + "/" + filePath)
            }
        }
    }
}
