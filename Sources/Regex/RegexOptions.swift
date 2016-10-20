//===--- RegexOptions.swift ------------------------------------------------------===//
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
//import Boilerplate

public struct RegexOptions : OptionSet {
    public let rawValue: UInt
    
    public init(rawValue: UInt) { self.rawValue = rawValue }
    
    public static let caseInsensitive = RegexOptions(rawValue: 1) /* Match letters in the pattern independent of case. */
    public static let allowCommentsAndWhitespace = RegexOptions(rawValue: 2) /* Ignore whitespace and #-prefixed comments in the pattern. */
    public static let ignoreMetacharacters = RegexOptions(rawValue: 4) /* Treat the entire pattern as a literal string. */
    public static let dotMatchesLineSeparators = RegexOptions(rawValue: 8) /* Allow . to match any character, including line separators. */
    public static let anchorsMatchLines = RegexOptions(rawValue: 16) /* Allow ^ and $ to match the start and end of lines. */
    public static let useUnixLineSeparators = RegexOptions(rawValue: 32) /* Treat only \n as a line separator (otherwise, all standard line separators are used). */
    public static let useUnicodeWordBoundaries = RegexOptions(rawValue: 64) /* Use Unicode TR#29 to specify word boundaries (otherwise, traditional regular expression word boundaries are used). */
    public static let defaultOptions:RegexOptions = [caseInsensitive]
    public static let none:RegexOptions = []
}

//#if !os(Linux)
//    public typealias RegularExpression = NSRegularExpression
//#else
//    public extension RegularExpression {
//        public typealias MatchingOptions = NSMatchingOptions
//    }
//#endif

public typealias RegularExpression = NSRegularExpression

extension RegularExpression.Options : Hashable {
    public var hashValue: Int {
        get {
            return Int(rawValue)
        }
    }
}

extension RegexOptions : Hashable {
    public var hashValue: Int {
        get {
            return Int(rawValue)
        }
    }
}

private let nsToRegexOptionsMap:Dictionary<RegularExpression.Options, RegexOptions> = [
    .caseInsensitive:.caseInsensitive,
    .allowCommentsAndWhitespace:.allowCommentsAndWhitespace,
    .ignoreMetacharacters:.ignoreMetacharacters,
    .dotMatchesLineSeparators:.dotMatchesLineSeparators,
    .anchorsMatchLines:.anchorsMatchLines,
    .useUnixLineSeparators:.useUnixLineSeparators,
    .useUnicodeWordBoundaries:.useUnicodeWordBoundaries]

private let regexToNSOptionsMap:Dictionary<RegexOptions, RegularExpression.Options> = nsToRegexOptionsMap.map({ (key, value) in
        return (value, key)
    }).reduce([:], { (dict, kv) in
        var dict = dict
        dict[kv.0] = kv.1
        return dict
    })

public extension RegexOptions {
    public var ns:RegularExpression.Options {
        get {
            let nsSeq = regexToNSOptionsMap.filter { (regex, _) in
                self.contains(regex)
            }.map { (_, ns) in
                ns
            }
            
            return RegularExpression.Options(nsSeq)
        }
    }
}

public extension RegularExpression.Options {
    public var regex:RegexOptions {
        get {
            let regexSeq = nsToRegexOptionsMap.filter { (ns, _) in
                self.contains(ns)
            }.map { (_, regex) in
                regex
            }
            
            return RegexOptions(regexSeq)
        }
    }
}
