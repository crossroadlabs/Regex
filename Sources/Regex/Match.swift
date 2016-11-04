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


//Make this one public when we add a second implementation
protocol MatchProtocol {
    var source:String {get}
    
    var range:StringRange {get}
    var ranges:[StringRange?] {get}
    
    func range(at index:Int) -> StringRange?
    func range(named name:String) -> StringRange?
    
    var matched:String {get}
    var subgroups:[String?] {get}
    
    func group(at index:Int) -> String?
    func group(named name:String) -> String?
}

/**
 * Represents a pattern match
 */
public class Match : MatchProtocol {
    /**
     * The original string supplied to Regex for matching
     */
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
    
    func index(of group:String) -> Int {
        return nameMap[group]! + 1
    }
    
    /**
     * The matching range
     */
    public var range:StringRange {
        get {
            //here it never throws, because otherwise it will not match
            return try! match.range.asRange(ofString: source)
        }
    }
    
    /**
     * The matching ranges of subgroups
     */
    public var ranges:[StringRange?] {
        get {
            var result = Array<StringRange?>()
            for i in 0..<match.numberOfRanges {
                //subrange can be empty
                
                let stringRange = try? match.range(at: i).asRange(ofString: source)
                
                result.append(stringRange)
            }
            return result
        }
    }
    
    /**
     * Takes a subgroup match by index.
     
     - parameter index: Number of subgroup to match to. Zero represents the whole match.
     - returns: A range or nil if the supplied subgroup does not exist.
     */
    public func range(at index:Int) -> StringRange? {
        return try? match.range(at: index).asRange(ofString: source)
    }
    
    /**
     * Takes a subgroup match range by name. This will work if you suuplied subgroup names while creating Regex.
     
     - parameter name: Name of subgroup to match to.
     - returns: A range or nil if the supplied subgroup does not exist.
     */
    public func range(named name:String) -> StringRange? {
        //subrange can be empty
        return try? match.range(at: index(of: name)).asRange(ofString: source)
    }

    /**
     * The whole matched substring.
     */
    public var matched:String {
        get {
            //zero group is always there, otherwise there is no match
            return group(at: 0)!
        }
    }
    
    /**
     * Matched subgroups' substrings.
     */
    public var subgroups:[String?] {
        get {
            
            let subRanges = ranges.suffix(from: 1)
            return subRanges.map { range in
                range.map { range in
                    source.substring(with: range)
                }
            }
        }
    }
    
    /**
     * Takes a subgroup match substring by index.
     
     - parameter name: Index of subgroup to match to. Zero represents the whole match.
     - returns: A substring or nil if the supplied subgroup does not exist.
     */
    public func group(at index:Int) -> String? {
        let range = self.range(at: index)
        return range.map { range in
            source.substring(with: range)
        }
    }
    
    /**
     * Takes a subgroup match substring by name. This will work if you suuplied subgroup names while creating Regex.
     
     - parameter name: Index of subgroup to match to.
     - returns: A substring or nil if the supplied subgroup does not exist.
     */
    public func group(named name:String) -> String? {
        return self.group(at: index(of: name))
    }
}
