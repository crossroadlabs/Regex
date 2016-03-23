//===--- Match.swift ------------------------------------------------------===//
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

public protocol MatchType {
    var source:String {get}
    
    var range:StringRange {get}
    var ranges:[StringRange?] {get}
    
    func range(atIndex:Int) -> StringRange?
    func range(byName:String) -> StringRange?
    
    var matched:String {get}
    var subgroups:[String?] {get}
    
    func group(atIndex:Int) -> String?
    func group(byName:String) -> String?
}

public class Match : MatchType {
    public let source:String
    
    let match:CompiledPatternMatch
    let groupNames:[String]
    let nameMap:Dictionary<String, Int>
    
    init(source:String, match:CompiledPatternMatch, groupNames:[String]) {
        self.source = source
        self.match = match
        self.groupNames = groupNames
        self.nameMap = groupNames.indexHash
    }
    
    func groupIndex(group:String) -> Int {
        return nameMap[group]! + 1
    }
    
    public var range:StringRange {
        get {
            //here it never throws, because otherwise it will not match
            return try! match.range.toStringRange(source)
        }
    }
    
    public var ranges:[StringRange?] {
        get {
            var result = Array<StringRange?>()
            for i in 0..<match.numberOfRanges {
                //subrange can be empty
                #if swift(>=3.0)
                    let stringRange = try? match.range(at: i).toStringRange(source)
                #else
                    let stringRange = try? match.rangeAtIndex(i).toStringRange(source)
                #endif
                result.append(stringRange)
            }
            return result
        }
    }
    
    public func range(atIndex:Int) -> StringRange? {
        //subrange can be empty
        #if swift(>=3.0)
            return try? match.range(at: atIndex).toStringRange(source)
        #else
            return try? match.rangeAtIndex(atIndex).toStringRange(source)
        #endif
    }
    
    public func range(byName:String) -> StringRange? {
        //subrange can be empty
        #if swift(>=3.0)
            return try? match.range(at: groupIndex(byName)).toStringRange(source)
        #else
            return try? match.rangeAtIndex(groupIndex(byName)).toStringRange(source)
        #endif
    }

    public var matched:String {
        get {
            //zero group is always there, otherwise there is no match
            return group(0)!
        }
    }
    
    public var subgroups:[String?] {
        get {
            #if swift(>=3.0)
                let subRanges = ranges.suffix(from: 1)
            #else
                let subRanges = ranges.suffixFrom(1)
            #endif
            return subRanges.map { range in
                range.map { range in
                    source.substringWithRange(range)
                }
            }
        }
    }
    
    public func group(atIndex:Int) -> String? {
        let range = self.range(atIndex)
        return range.map { range in
            source.substringWithRange(range)
        }
    }
    
    public func group(byName:String) -> String? {
        return self.group(groupIndex(byName))
    }
}
