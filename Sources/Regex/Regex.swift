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

/**
 * Regular Expression protocol
 *
 * Makes it easier to maintain two implementations
 */
public protocol RegexProtocol {
    /**
     Constructor, same as main, more lightweight (omits options). Can throw an error.
     
     - parameters:
       - pattern: A pattern to be used with Regex
       - groupNames: Group names to be used for matching
     */
    init(pattern:String, groupNames:[String]) throws
    
    /**
     Constructor, same as main, more lightweight (omits options); group names can be supplied as var args.
     Can throw an error.
     
     - parameters:
       - pattern: A pattern to be used with Regex
       - groupNames: Group names to be used for matching
     */
    init(pattern:String, groupNames:String...) throws
    
    /**
     Main constructor. Can throw an error.
     
     - parameters:
       - pattern: A pattern to be used with Regex
       - options: RegexOptions, i.e. case sensitivity, etc.
       - groupNames: Group names to be used for matching
     */
    init(pattern:String, options:RegexOptions, groupNames:[String]) throws
    
    /**
     Constructor, same as main, but group names can be supplied as var args. Can throw an error.
     
     - parameters:
       - pattern: A pattern to be used with Regex
       - options: RegexOptions, i.e. case sensitivity, etc.
       - groupNames: Group names to be used for matching
     */
    init(pattern:String, options:RegexOptions, groupNames:String...) throws
    
    /**
     * Pattern used to create this Regex
     */
    var pattern:String {get}
    
    /**
     * Group names that will be used for named patter matching. Are supplied in a constructor.
     */
    var groupNames:[String] {get}
    
    /**
     Checks is supplied string matches the pattern.
     
     - parameters:
       - source: String to be matched to the pattern
     - returns: True if the source matches, false otherwise.
     */
    func matches(_ source:String) -> Bool
    
    /**
     Finds all the matches in the supplied string
     
     - parameters:
       - source: String to be matched to the pattern
     - returns: A sequence of found matches. Can be empty if nothing was found.
     */
    func findAll(in source:String) -> MatchSequence
    
    /**
     Returns the first match in the supplied string
     
     - parameters:
       - source: String to be matched to the pattern
     - returns: The match. Can be .none if nothing was found
     */
    func findFirst(in source:String) -> Match?
    
    /**
     Replaces all occurrences of the pattern using supplied replacement String.
     
     - parameters:
       - source: String to be matched to the pattern
       - replacement: Replacement string. Can use $1, $2, etc. to insert matched groups.
     - returns: A string, where all the occurrences of the pattern were replaced.
     */
    func replaceAll(in source:String, with replacement:String) -> String
    
    /**
     Replaces all occurrences of the pattern using supplied replacer function.
     
     - parameters:
       - source: String to be matched to the pattern
       - replacer: Function that takes a match and returns a replacement. If replacement is nil, the original match gets inserted instead
     - returns: A string, where all the occurrences of the pattern were replaced
     */
    func replaceAll(in source:String, using replacer:(Match) -> String?) -> String
    
    /**
     Replaces first occurrence of the pattern using supplied replacement String.
     
     - parameters:
       - source: String to be matched to the pattern
       - replacement: Replacement string. Can use $1, $2, etc. to insert matched groups.
     - returns: A string, where the first occurrence of the pattern was replaced.
     */
    func replaceFirst(in source:String, with replacement:String) -> String
    
    /**
     Replaces the first occurrence of the pattern using supplied replacer function.
     
     - parameters:
       - source: String to be matched to the pattern
       - replacer: Function that takes a match and returns a replacement. If replacement is nil, the original match gets inserted instead
     - returns: A string, where the first occurrence of the pattern was replaced
     */
    func replaceFirst(in source:String, using replacer:(Match) -> String?) -> String
    
    /**
     Splits the content of supplied string by pattern.
     In case the pattern contains subgroups, they are added to the resulting array as well.
     
     - parameters:
       - source: String to be split
     - returns: Array of pieces of the string split with the pattern delimiter.
     */
    func split(_ source:String) -> [String]
}

/**
 * Regular Expression
 */
public class Regex : RegexProtocol {
    /**
     * Pattern used to create this Regex
     */
    public let pattern:String
    
    /**
     * Group names that will be used for named patter matching. Are supplied in a constructor.
     */
    public let groupNames:[String]
    private let compiled:CompiledPattern?
    
    /**
     Main constructor. Can throw an error.
     
     - parameters:
       - pattern: A pattern to be used with Regex
       - options: RegexOptions, i.e. case sensitivity, etc.
       - groupNames: Group names to be used for matching
     */
    public required init(pattern:String, options:RegexOptions, groupNames:[String]) throws {
        self.pattern = pattern
        self.groupNames = groupNames
        do {
            self.compiled = try type(of: self).compile(pattern: pattern, options: options)
        } catch let e {
            self.compiled = nil
            throw e
        }
    }
    
    /**
     Constructor, same as main, but group names can be supplied as var args. Can throw an error.
     
     - parameters:
       - pattern: A pattern to be used with Regex
       - options: RegexOptions, i.e. case sensitivity, etc.
       - groupNames: Group names to be used for matching
     */
    public required convenience init(pattern:String, options:RegexOptions, groupNames:String...) throws {
        try self.init(pattern:pattern, options: options, groupNames:groupNames)
    }
    
    /**
     Constructor, same as main, more lightweight (omits options). Can throw an error.
     
     - parameters:
       - pattern: A pattern to be used with Regex
       - groupNames: Group names to be used for matching
     */
    public required convenience init(pattern: String, groupNames: [String]) throws {
        try self.init(pattern:pattern, options: .`default`, groupNames:groupNames)
    }
    
    /**
     Constructor, same as main, more lightweight (omits options); group names can be supplied as var args.
     Can throw an error.
     
     - parameters:
       - pattern: A pattern to be used with Regex
       - groupNames: Group names to be used for matching
     */
    public required convenience init(pattern: String, groupNames: String...) throws {
        try self.init(pattern:pattern, groupNames:groupNames)
    }
    
    private static func compile(pattern:String, options:RegexOptions) throws -> CompiledPattern {
        //pass options
        return try NSRegularExpression(pattern: pattern, options: options.ns)
    }
    
    /**
     Finds all the matches in the supplied string
     
     - parameters:
       - source: String to be matched to the pattern
     - returns: A sequence of found matches. Can be empty if nothing was found.
     */
    public func findAll(in source:String) -> MatchSequence {
        let options = NSRegularExpression.MatchingOptions(rawValue: 0)
        let range = GroupRange(location: 0, length: source.count)
        let context = compiled?.matches(in: source, options: options, range: range)
        //hard unwrap of context, because the instance would not exist without it
        return MatchSequence(source: source, context: context!, groupNames: groupNames)
    }
    
    /**
     Returns the first match in the supplied string
     
     - parameters:
       - source: String to be matched to the pattern
     - returns: The match. Can be .none if nothing was found
     */
    public func findFirst(in source:String) -> Match? {
        let options = NSRegularExpression.MatchingOptions(rawValue: 0)
        let range = GroupRange(location: 0, length: source.count)
        let match = compiled?.firstMatch(in: source, options: options, range: range)
        return match.map { match in
            Match(source: source, match: match, groupNames: groupNames)
        }
    }
    
    /**
     Replaces all occurrences of the pattern using supplied replacement String.
     
     - parameters:
       - source: String to be matched to the pattern
       - replacement: Replacement string. Can use $1, $2, etc. to insert matched groups.
     - returns: A string, where all the occurrences of the pattern were replaced.
     */
    public func replaceAll(in source:String, with replacement:String) -> String {
        let options = NSRegularExpression.MatchingOptions(rawValue: 0)
        let range = GroupRange(location: 0, length: source.count)
        
        return compiled!.stringByReplacingMatches(in: source, options: options, range: range, withTemplate: replacement)
    }
    
    /**
     Replaces first occurrence of the pattern using supplied replacement String.
     
     - parameters:
       - source: String to be matched to the pattern
       - replacement: Replacement string. Can use $1, $2, etc. to insert matched groups.
     - returns: A string, where the first occurrence of the pattern was replaced.
     */
    public func replaceFirst(in source:String, with replacement:String) -> String {
        return replaceFirst(in: source) { match in
            return self.compiled!.replacementString(for: match.match, in: source, offset: 0, template: replacement)
        }
    }
    
    private func replaceMatches<T: Sequence>(in source:String, matches:T, using replacer:(Match) -> String?) -> String where T.Iterator.Element : Match {
        var result = ""
        var lastRange:StringRange = source.startIndex ..< source.startIndex
        for match in matches {
            result += source[lastRange.upperBound ..< match.range.lowerBound]
            if let replacement = replacer(match) {
                result += replacement
            } else {
                result += source[match.range]
            }
            lastRange = match.range
        }
        result += source[lastRange.upperBound...]
        return result
    }
    
    /**
     Checks is supplied string matches the pattern.
     
     - parameters:
       - source: String to be matched to the pattern
     - returns: True if the source matches, false otherwise.
     */
    public func matches(_ source:String) -> Bool {
        guard let _ = findFirst(in: source) else {
            return false
        }
        return true
    }
    
    /**
     Replaces all occurrences of the pattern using supplied replacer function.
     
     - parameters:
       - source: String to be matched to the pattern
       - replacer: Function that takes a match and returns a replacement. If replacement is nil, the original match gets inserted instead
     - returns: A string, where all the occurrences of the pattern were replaced
     */
    public func replaceAll(in source:String, using replacer:(Match) -> String?) -> String {
        let matches = findAll(in: source)
        return replaceMatches(in: source, matches: matches, using: replacer)
    }
    
    /**
     Replaces the first occurrence of the pattern using supplied replacer function.
     
     - parameters:
       - source: String to be matched to the pattern
       - replacer: Function that takes a match and returns a replacement. If replacement is nil, the original match gets inserted instead
     - returns: A string, where the first occurrence of the pattern was replaced
     */
    public func replaceFirst(in source:String, using replacer:(Match) -> String?) -> String {
        var matches = Array<Match>()
        if let match = findFirst(in: source) {
            matches.append(match)
        }
        return replaceMatches(in: source, matches: matches, using: replacer)
    }
    
    /**
     Splits the content of supplied string by pattern.
     In case the pattern contains subgroups, they are added to the resulting array as well.
     
     - parameters:
       - source: String to be split
     - returns: Array of pieces of the string split with the pattern delimiter.
     */
    public func split(_ source:String) -> [String] {
        var result = Array<String>()
        let matches = findAll(in: source)
        var lastRange:StringRange = source.startIndex ..< source.startIndex
        for match in matches {
            //extract the piece before the match
            let range = lastRange.upperBound ..< match.range.lowerBound
            let piece = String(source[range])
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
        let rest = String(source[lastRange.upperBound...])
        result.append(rest)
        return result
    }
}
