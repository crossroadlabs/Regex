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

#if os(OSX)
    import CIcuRegex
#else
    import Foundation
#endif
    public class MatchSequence : SequenceType {
        let source:String
        let context:CompiledMatchContext
        let groupNames:[String]
        
        init(source:String, context:CompiledMatchContext, groupNames:[String]) {
            self.source = source
            self.context = context
            self.groupNames = groupNames
        }
        
        public typealias Generator = AnyGenerator<Match>
        /// A type that represents a subsequence of some of the elements.
        
    #if os(OSX)
        public func generate() -> Generator {
            return anyGenerator {
                var ec = U_ZERO_ERROR
                if uregex_findNext_56(self.context.icu, &ec) != 0 {
                    let compiledMatch = CompiledPatternMatch.fromIcuMatch(self.context)
                    return Match(source: self.source, match: compiledMatch!, groupNames: self.groupNames)
                } else {
                    return nil
                }
            }
        }
    #else
        public func generate() -> Generator {
            var index = context.startIndex
            
            return anyGenerator {
                if self.context.endIndex > index {
                    let result = Match(source: self.source, match: self.context[index], groupNames: self.groupNames)
                    index = index.advancedBy(1)
                    return result
                } else {
                    return nil
                }
            }
        }
    #endif
    }