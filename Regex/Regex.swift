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

//TODO: implement with PCRE
//TODO: implement sintactic sugar operators

#if os(Linux)
    import CIcuRegex
#else
    import Foundation
#endif

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
    
#if os(Linux)
    private static func compile(pattern:String) throws -> CompiledPattern {
        var ec = U_ZERO_ERROR
        let utext = try ICUText(string: pattern)
        let pattern = uregex_openUText_56(utext.icu, UREGEX_CASE_INSENSITIVE.rawValue, nil, &ec)
        if ec != U_ZERO_ERROR {
            throw RegexError.CompilationError(errorCode:Int(ec.rawValue))
        }
        return CompiledPattern(icu:pattern, text: utext)
    }
    
    public func findAll(source:String) -> MatchSequence {
        guard let matcher = compiled else {
            print("ICU regex object are nill")
            exit(1)
        }
        var ec = U_ZERO_ERROR
        let context = uregex_clone_56(matcher.icu, &ec)
        guard ec == U_ZERO_ERROR else {
            print("Error on copying of ICU regex object \(ec) ")
            exit(ec.rawValue)
        }
        guard let utext = try? ICUText(string:source) else {
            uregex_close_56(context)
            print("Error on converting to UText")
            exit(1)
        }
        uregex_setUText_56(context, utext.icu, &ec)
        guard ec == U_ZERO_ERROR else {
            uregex_close_56(context)
            print("Can't set string to ICU regex object \(ec) ")
            exit(ec.rawValue)
        }
        return MatchSequence(source: source, context: CompiledPattern(icu:context, text:utext), groupNames: groupNames)
    }
    
    public func findFirst(source:String) -> Match? {
        return findAll(source).generate().next()
    }
    
    public func replaceAll(source:String, replacement:String) -> String {
        guard let matcher = compiled else {
            print("ICU regex object are nill")
            exit(1)
        }
        var ec = U_ZERO_ERROR
        let context = uregex_clone_56(matcher.icu, &ec)
        guard ec == U_ZERO_ERROR else {
            print("Error on copying of ICU regex object \(ec) ")
            exit(ec.rawValue)
        }
        guard let from = try? ICUText(string:source) else {
            print("Error on converting to UText")
            uregex_close_56(context)
            exit(1)
        }
        uregex_setUText_56(context, from.icu, &ec)
        guard ec == U_ZERO_ERROR else {
            uregex_close_56(context)
            print("Can't set string to ICU regex object \(ec) ")
            exit(ec.rawValue)
        }
        
        guard let replace = try? ICUText(string: replacement) else {
            print("Error on converting to UText")
            uregex_close_56(context)
            exit(1)
        }
        
        let result = uregex_replaceAllUText_56(context, replace.icu, nil, &ec)
        
        guard ec == U_ZERO_ERROR else {
            uregex_close_56(context)
            print("Can't call replace all \(ec) ")
            exit(ec.rawValue)
        }
        
        var resultString = try? ICUText(icu:result).toString()
        if resultString == nil {
            resultString = source
        }
        uregex_close_56(context)
        return resultString!
    }
    
    public func replaceFirst(source:String, replacement:String) -> String {
        guard let matcher = compiled else {
            print("ICU regex object are nill")
            exit(1)
        }
        var ec = U_ZERO_ERROR
        let context = uregex_clone_56(matcher.icu, &ec)
        guard ec == U_ZERO_ERROR else {
            print("Error on copying of ICU regex object \(ec) ")
            exit(ec.rawValue)
        }
        guard let from = try? ICUText(string:source) else {
            print("Error on converting to UText")
            uregex_close_56(context)
            exit(1)
        }
        uregex_setUText_56(context, from.icu, &ec)
        guard ec == U_ZERO_ERROR else {
            uregex_close_56(context)
            print("Can't set string to ICU regex object \(ec) ")
            exit(ec.rawValue)
        }
        
        guard let replace = try? ICUText(string:replacement) else {
            print("Error on converting to UText")
            uregex_close_56(context)
            exit(1)
        }
        
        let result = uregex_replaceFirstUText_56(context, replace.icu, nil, &ec)
        
        guard ec == U_ZERO_ERROR else {
            uregex_close_56(context)
            print("Can't call replace all \(ec) ")
            exit(ec.rawValue)
        }
        
        var resultString = try? ICUText(icu:result).toString()
        if resultString == nil {
            resultString = source
        }
        uregex_close_56(context)
        return resultString!
    }
    
#else
    private static func compile(pattern:String) throws -> CompiledPattern {
        //pass options
        return try NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.CaseInsensitive)
    }
    
    public func findAll(source:String) -> MatchSequence {
        let options = NSMatchingOptions(rawValue: 0)
        let range = NSRange(location: 0, length: source.characters.count)
        let context = compiled?.matchesInString(source, options: options, range: range)
        //hard unwrap of context, because the instance would not exist without it
        return MatchSequence(source: source, context: context!, groupNames: groupNames)
    }
    
    public func findFirst(source:String) -> Match? {
        let options = NSMatchingOptions(rawValue: 0)
        let range = NSRange(location: 0, length: source.characters.count)
        let match = compiled?.firstMatchInString(source, options: options, range: range)
        return match.map { match in
            Match(source: source, match: match, groupNames: groupNames)
        }
    }
    
    public func replaceAll(source:String, replacement:String) -> String {
        let options = NSMatchingOptions(rawValue: 0)
        let range = NSRange(location: 0, length: source.characters.count)
        return compiled!.stringByReplacingMatchesInString(source, options: options, range: range, withTemplate: replacement)
    }
    
    public func replaceFirst(source:String, replacement:String) -> String {
        return replaceFirst(source) { match in
            self.compiled!.replacementStringForResult(match.match, inString: source, offset: 0, template: replacement)
        }
    }
#endif

    private func replaceMatches<T: SequenceType where T.Generator.Element : Match>(source:String, matches:T, replacer:Match -> String?) -> String {
        var result = ""
        var lastRange:StringRange = StringRange(start: source.startIndex, end: source.startIndex)
        for match in matches {
            result += source.substringWithRange(Range(start: lastRange.endIndex, end:match.range.startIndex))
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
        var lastRange:StringRange = StringRange(start: source.startIndex, end: source.startIndex)
        for match in matches {
            //extract the piece before the match
            let range = StringRange(start: lastRange.endIndex, end: match.range.startIndex)
            let piece = source.substringWithRange(range)
            result.append(piece)
            lastRange = match.range
            
            //add subgroups
            result.appendContentsOf(match.subgroups.filter { subgroup in
                subgroup != nil
            }.map { subgroup in
                subgroup!
            })
        }
        let rest = source.substringFromIndex(lastRange.endIndex)
        result.append(rest)
        return result
    }
}