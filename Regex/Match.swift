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

public protocol MatchType {
    var range:StringRange {get}
    var ranges:[StringRange] {get}
    
    func range(atIndex:Int) -> StringRange
    func range(byName:String) -> StringRange
    
    func group(atIndex:Int) -> String
    func group(byName:String) -> String
}

public class Match : MatchType {
    let source:String
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
    
#if os(Linux)
    //TODO: implement with PCRE
#else
    public var range:StringRange {
        get {
            return match.range.toStringRange(source)
        }
    }
    
    public var ranges:[StringRange] {
        get {
            var result = Array<StringRange>()
            for(var i:Int = 0; i < match.numberOfRanges; i++) {
                result.append(match.rangeAtIndex(i).toStringRange(source))
            }
            return result
        }
    }
    
    public func range(atIndex:Int) -> StringRange {
        return match.rangeAtIndex(atIndex).toStringRange(source)
    }
    
    public func range(byName:String) -> StringRange {
        return match.rangeAtIndex(groupIndex(byName)).toStringRange(source)
    }
#endif
    public var matched:String {
        get {
            return group(0)
        }
    }
    
    public var subgroups:[String] {
        get {
            return ranges.suffixFrom(1).map { range in
                source.substringWithRange(range)
            }
        }
    }
    
    public func group(atIndex:Int) -> String {
        let range = self.range(atIndex)
        return source.substringWithRange(range)
    }
    
    public func group(byName:String) -> String {
        return self.group(groupIndex(byName))
    }
}
