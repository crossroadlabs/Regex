//===--- Utils.swift ------------------------------------------------------===//
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

public typealias StringRange = Range<String.Index>

extension Sequence where Iterator.Element : Hashable {
    var indexHash:Dictionary<Iterator.Element, Int> {
        get {
            var result = Dictionary<Iterator.Element, Int>()
            var index = 0
            for e in self {
                result[e] = index
                index += 1
            }
            return result
        }
    }
}
