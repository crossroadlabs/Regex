//===--- MatchSequence.swift ----------------------------------------------===//
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

/**
 * Match sequence is a sequence given as a result of findAll operation.
 */
public class MatchSequence : Sequence {
    let source:String
    let context:CompiledMatchContext
    let groupNames:[String]
        
    init(source:String, context:CompiledMatchContext, groupNames:[String]) {
        self.source = source
        self.context = context
        self.groupNames = groupNames
    }
    
    public typealias Iterator = AnyIterator<Match>
    
    /**
     * Method is required by the Sequence protocol
     */
    public func makeIterator() -> Iterator {
        var index = context.startIndex
        
        return Iterator {
            if self.context.endIndex > index {
                let result = Match(source: self.source, match: self.context[index], groupNames: self.groupNames)
                
                index = index.advanced(by: 1)
                
                return result
            } else {
                return nil
            }
        }
    }
}
