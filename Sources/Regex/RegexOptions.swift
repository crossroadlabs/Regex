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

/**
 Options that can be used to modify the default Regex behaviour.
 Can be user while the Regex is constructed.
 
 - see: Regex.init
 */
public struct RegexOptions : OptionSet {
    /**
     Required by OptionSet protocol. Can be used to obtain integer value of a flag set
    */
    public let rawValue: UInt
    
    /**
     Required by OptionSet protocol.
     Can be used for construction of OptionSet from integer based flags.
     
     - see: rawValue
    */
    public init(rawValue: UInt) { self.rawValue = rawValue }
    
    /**
     * Match letters in the pattern independent of case.
     */
    public static let caseInsensitive = RegexOptions(rawValue: 1)
    
    /**
     * Ignore whitespace and #-prefixed comments in the pattern.
     */
    public static let allowCommentsAndWhitespace = RegexOptions(rawValue: 2)
    
    /**
     * Treat the entire pattern as a literal string.
     */
    public static let ignoreMetacharacters = RegexOptions(rawValue: 4)
    
    /**
     * Allow . to match any character, including line separators.
     */
    public static let dotMatchesLineSeparators = RegexOptions(rawValue: 8)
    
    /**
     * Allow ^ and $ to match the start and end of lines.
     */
    public static let anchorsMatchLines = RegexOptions(rawValue: 16)
    
    /**
     * Treat only \n as a line separator (otherwise, all standard line separators are used).
     */
    public static let useUnixLineSeparators = RegexOptions(rawValue: 32)
    
    /**
     * Use Unicode TR#29 to specify word boundaries (otherwise, traditional regular expression word boundaries are used).
     */
    public static let useUnicodeWordBoundaries = RegexOptions(rawValue: 64)
    
    
    /**
     * Options used by default in Regex
     */
    public static let `default`:RegexOptions = [caseInsensitive]
}

/**
 * Internal implementation that can't be hidden. Skip it.
 */
extension NSRegularExpression.Options : Hashable {
	/**
     * Internal implementation that can't be hidden. Skip it.
     */
    public var hashValue: Int {
        get {
            return Int(rawValue)
        }
    }
}

/**
 * Allows to RegexOptions to be used as keys for Dictionaries. Required for internal implementation.
 */
extension RegexOptions : Hashable {
    /**
     * Required by Hashable
     */
    public var hashValue: Int {
        get {
            return Int(rawValue)
        }
    }
}

private let nsToRegexOptionsMap:[NSRegularExpression.Options: RegexOptions] = [
    .caseInsensitive:.caseInsensitive,
    .allowCommentsAndWhitespace:.allowCommentsAndWhitespace,
    .ignoreMetacharacters:.ignoreMetacharacters,
    .dotMatchesLineSeparators:.dotMatchesLineSeparators,
    .anchorsMatchLines:.anchorsMatchLines,
    .useUnixLineSeparators:.useUnixLineSeparators,
    .useUnicodeWordBoundaries:.useUnicodeWordBoundaries
]

private let regexToNSOptionsMap:[RegexOptions: NSRegularExpression.Options] = nsToRegexOptionsMap.reduce([:]) { (dict, kv) in
    var dict = dict
    dict[kv.value] = kv.key
    return dict
}

extension RegexOptions {
    var ns: NSRegularExpression.Options {
        get {
            let nsSeq = regexToNSOptionsMap.filter { (regex, _) in
                self.contains(regex)
            }.map { (_, ns) in
                ns
            }
            
            return NSRegularExpression.Options(nsSeq)
        }
    }
}

extension NSRegularExpression.Options {
    var regex:RegexOptions {
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
