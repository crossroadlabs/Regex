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
    
    var pattern:String {get}
    var groupNames:[String] {get}
    
    func matches(source:String) -> Bool
    
    func findAll(source:String) -> MatchSequence
    func findFirst(source:String) -> Match?
    
    func replaceAll(source:String, replacement:String) -> String
    func replaceAll(source:String, replacer:Match -> String?) -> String
    func replaceFirst(source:String, replacement:String) -> String
    func replaceFirst(source:String, replacer:Match -> String?) -> String
    
    func split(source:String) -> [String]
}

public class Regex : RegexType {
    public let pattern:String
    public let groupNames:[String]
    private let compiled:CompiledPattern?
    
    public required init(pattern:String, groupNames:[String]) throws {
        self.pattern = pattern
        self.groupNames = groupNames
        do {
            self.compiled = try self.dynamicType.compile(pattern)
        } catch let e {
            self.compiled = nil
            throw e
        }
    }
    
    public required convenience init(pattern:String, groupNames:String...) throws {
        try self.init(pattern:pattern, groupNames:groupNames)
    }
    
    private static func compile(pattern:String) throws -> CompiledPattern {
        //pass options
        #if swift(>=3.0)
            let options = NSRegularExpressionOptions.caseInsensitive
        #else
            let options = NSRegularExpressionOptions.CaseInsensitive
        #endif
        
        return try NSRegularExpression(pattern: pattern, options: options)
    }
    
    public func findAll(source:String) -> MatchSequence {
        let options = NSMatchingOptions(rawValue: 0)
        let range = NSRange(location: 0, length: source.characters.count)
        #if swift(>=3.0)
            let context = compiled?.matches(in: source, options: options, range: range)
        #else
            let context = compiled?.matchesInString(source, options: options, range: range)
        #endif
        //hard unwrap of context, because the instance would not exist without it
        return MatchSequence(source: source, context: context!, groupNames: groupNames)
    }
    
    public func findFirst(source:String) -> Match? {
        let options = NSMatchingOptions(rawValue: 0)
        let range = NSRange(location: 0, length: source.characters.count)
        #if swift(>=3.0)
            let match = compiled?.firstMatch(in: source, options: options, range: range)
        #else
            let match = compiled?.firstMatchInString(source, options: options, range: range)
        #endif
        return match.map { match in
            Match(source: source, match: match, groupNames: groupNames)
        }
    }
    
    public func replaceAll(source:String, replacement:String) -> String {
        let options = NSMatchingOptions(rawValue: 0)
        let range = NSRange(location: 0, length: source.characters.count)
        #if swift(>=3.0)
            return compiled!.stringByReplacingMatches(in: source, options: options, range: range, withTemplate: replacement)
        #else
            return compiled!.stringByReplacingMatchesInString(source, options: options, range: range, withTemplate: replacement)
        #endif
    }
    
    public func replaceFirst(source:String, replacement:String) -> String {
        return replaceFirst(source) { match in
            #if swift(>=3.0)
                return self.compiled!.replacementString(for: match.match, in: source, offset: 0, template: replacement)
            #else
                return self.compiled!.replacementStringForResult(match.match, inString: source, offset: 0, template: replacement)
            #endif
        }
    }
    
    #if swift(>=3.0)
        private func replaceMatches<T: Sequence where T.Iterator.Element : Match>(source:String, matches:T, replacer:Match -> String?) -> String {
            var result = ""
            var lastRange:StringRange = source.startIndex ..< source.startIndex
            for match in matches {
                result += source.substringWithRange(lastRange.endIndex ..< match.range.startIndex)
                if let replacement = replacer(match) {
                    result += replacement
                } else {
                    result += source.substringWithRange(match.range)
                }
                lastRange = match.range
            }
            result += source.substringFromIndex(lastRange.endIndex)
            return result
        }
    #else
        private func replaceMatches<T: Sequence where T.Generator.Element : Match>(source:String, matches:T, replacer:Match -> String?) -> String {
            var result = ""
            var lastRange:StringRange = source.startIndex ..< source.startIndex
            for match in matches {
                result += source.substringWithRange(lastRange.endIndex ..< match.range.startIndex)
                if let replacement = replacer(match) {
                    result += replacement
                } else {
                    result += source.substringWithRange(match.range)
                }
                lastRange = match.range
            }
            result += source.substringFromIndex(lastRange.endIndex)
            return result
        }
    #endif
    
    public func matches(source:String) -> Bool {
        guard let _ = findFirst(source) else {
            return false
        }
        return true
    }
    
    public func replaceAll(source:String, replacer:Match -> String?) -> String {
        let matches = findAll(source)
        return replaceMatches(source, matches: matches, replacer: replacer)
    }
    
    public func replaceFirst(source:String, replacer:Match -> String?) -> String {
        var matches = Array<Match>()
        if let match = findFirst(source) {
            matches.append(match)
        }
        return replaceMatches(source, matches: matches, replacer: replacer)
    }
    
    public func split(source:String) -> [String] {
        var result = Array<String>()
        let matches = findAll(source)
        var lastRange:StringRange = source.startIndex ..< source.startIndex
        for match in matches {
            //extract the piece before the match
            let range = lastRange.endIndex ..< match.range.startIndex
            let piece = source.substringWithRange(range)
            result.append(piece)
            lastRange = match.range
            
            let subgroups = match.subgroups.filter { subgroup in
                subgroup != nil
            }.map { subgroup in
                subgroup!
            }
            
            //add subgroups
            #if swift(>=3.0)
                result.append(contentsOf: subgroups)
            #else
                result.appendContentsOf(subgroups)
            #endif
        }
        let rest = source.substringFromIndex(lastRange.endIndex)
        result.append(rest)
        return result
    }
}
