//===--- Regex.swift ------------------------------------------------------===//
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

//makes it easier to maintain two implementations
public protocol RegexType {
    init(pattern:String, groupNames:[String]) throws
    init(pattern:String, groupNames:String...) throws
    init(pattern:String, options:RegexOptions, groupNames:[String]) throws
    init(pattern:String, options:RegexOptions, groupNames:String...) throws
    
    var pattern:String {get}
    var groupNames:[String] {get}
    
    func matches(_ source:String) -> Bool
    
    func findAll(in source:String) -> MatchSequence
    func findFirst(in source:String) -> Match?
    
    func replaceAll(in source:String, with replacement:String) -> String
    func replaceAll(in source:String, using replacer:(Match) -> String?) -> String
    func replaceFirst(in source:String, with replacement:String) -> String
    func replaceFirst(in source:String, using replacer:(Match) -> String?) -> String
    
    func split(_ source:String) -> [String]
}

public class Regex : RegexType {
    public let pattern:String
    public let groupNames:[String]
    private let compiled:CompiledPattern?
    
    public required init(pattern:String, options:RegexOptions, groupNames:[String]) throws {
        self.pattern = pattern
        self.groupNames = groupNames
        do {
            self.compiled = try self.dynamicType.compile(pattern: pattern, options: options)
        } catch let e {
            self.compiled = nil
            throw e
        }
    }
    
    public required convenience init(pattern:String, options:RegexOptions, groupNames:String...) throws {
        try self.init(pattern:pattern, options: options, groupNames:groupNames)
    }
    
    public required convenience init(pattern: String, groupNames: [String]) throws {
        try self.init(pattern:pattern, options: .defaultOptions, groupNames:groupNames)
    }
    
    public required convenience init(pattern: String, groupNames: String...) throws {
        try self.init(pattern:pattern, groupNames:groupNames)
    }
    
    private static func compile(pattern pattern:String, options:RegexOptions) throws -> CompiledPattern {
        //pass options
        return try RegularExpression(pattern: pattern, options: options.ns)
    }
    
    public func findAll(in source:String) -> MatchSequence {
        let options = RegularExpression.MatchingOptions(rawValue: 0)
        let range = NSRange(location: 0, length: source.characters.count)
        let context = compiled?.matches(in: source, options: options, range: range)
        //hard unwrap of context, because the instance would not exist without it
        return MatchSequence(source: source, context: context!, groupNames: groupNames)
    }
    
    public func findFirst(in source:String) -> Match? {
        let options = RegularExpression.MatchingOptions(rawValue: 0)
        let range = NSRange(location: 0, length: source.characters.count)
        let match = compiled?.firstMatch(in: source, options: options, range: range)
        return match.map { match in
            Match(source: source, match: match, groupNames: groupNames)
        }
    }
    
    public func replaceAll(in source:String, with replacement:String) -> String {
        let options = RegularExpression.MatchingOptions(rawValue: 0)
        let range = NSRange(location: 0, length: source.characters.count)
        
        return compiled!.stringByReplacingMatches(in: source, options: options, range: range, withTemplate: replacement)
    }
    
    public func replaceFirst(in source:String, with replacement:String) -> String {
        return replaceFirst(in: source) { match in
            return self.compiled!.replacementString(for: match.match, in: source, offset: 0, template: replacement)
        }
    }
    
    // Both functions the same. But in swift we can't ifdef only function declaration.
    #if swift(>=3.0)
        private func replaceMatches<T: Sequence where T.Iterator.Element : Match>(in source:String, matches:T, using replacer:(Match) -> String?) -> String {
            var result = ""
            var lastRange:StringRange = source.startIndex ..< source.startIndex
            for match in matches {
                result += source.substring(with: lastRange.upperBound ..< match.range.lowerBound)
                if let replacement = replacer(match) {
                    result += replacement
                } else {
                    result += source.substring(with: match.range)
                }
                lastRange = match.range
            }
            result += source.substring(from: lastRange.upperBound)
            return result
        }
    #else
        private func replaceMatches<T: Sequence where T.Generator.Element : Match>(in source:String, matches:T, using replacer:Match -> String?) -> String {
            var result = ""
            var lastRange:StringRange = source.startIndex ..< source.startIndex
            for match in matches {
                result += source.substring(with: lastRange.endIndex ..< match.range.startIndex)
                if let replacement = replacer(match) {
                    result += replacement
                } else {
                    result += source.substring(with: match.range)
                }
                lastRange = match.range
            }
            result += source.substring(from: lastRange.endIndex)
            return result
        }
    #endif
    
    public func matches(_ source:String) -> Bool {
        guard let _ = findFirst(in: source) else {
            return false
        }
        return true
    }
    
    public func replaceAll(in source:String, using replacer:(Match) -> String?) -> String {
        let matches = findAll(in: source)
        return replaceMatches(in: source, matches: matches, using: replacer)
    }
    
    public func replaceFirst(in source:String, using replacer:(Match) -> String?) -> String {
        var matches = Array<Match>()
        if let match = findFirst(in: source) {
            matches.append(match)
        }
        return replaceMatches(in: source, matches: matches, using: replacer)
    }
    
    public func split(_ source:String) -> [String] {
        var result = Array<String>()
        let matches = findAll(in: source)
        var lastRange:StringRange = source.startIndex ..< source.startIndex
        for match in matches {
            //extract the piece before the match
            let range = lastRange.upperBound ..< match.range.lowerBound
            let piece = source.substring(with: range)
            result.append(piece)
            lastRange = match.range
            
            let subgroups = match.subgroups.filter { subgroup in
                subgroup != nil
            }.map { subgroup in
                subgroup!
            }
            
            //add subgroups
            result.append(contentsOf: subgroups)
        }
        let rest = source.substring(from: lastRange.upperBound)
        result.append(rest)
        return result
    }
}
