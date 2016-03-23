//===--- GroupRangeUtils.swift --------------------------------------------===//
//Copyright (c) 2016 Daniel Leping (dileping)
//
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.
//===----------------------------------------------------------------------===//

import Foundation
import Boilerplate
    
enum InvalidRangeError : ErrorProtocol {
    case Error
}

extension GroupRange {
    func toStringRange(source:String) throws -> StringRange {
        let len = source.characters.count
        if self.location < 0 || self.location >= len || self.location + self.length > len {
            throw InvalidRangeError.Error
        }
        #if swift(>=3.0)
            let start = source.startIndex.advanced(by: self.location)
            let end = start.advanced(by: self.length)
        #else
            let start = source.startIndex.advancedBy(self.location)
            let end = start.advancedBy(self.length)
        #endif
        return start ..< end
    }
}
