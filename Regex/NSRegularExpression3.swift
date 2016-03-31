//
//  NSRegularExpression3.swift
//  Regex
//
//  Created by Yegor Popovych on 3/31/16.
//  Copyright © 2016 Crossroad Labs, LTD. All rights reserved.
//

import Foundation

#if swift(>=3.0) && !os(Linux)
#else
    public extension NSRegularExpressionOptions {
        public static var caseInsensitive = NSRegularExpressionOptions.CaseInsensitive
        public static var allowCommentsAndWhitespace = NSRegularExpressionOptions.AllowCommentsAndWhitespace
        public static var ignoreMetacharacters = NSRegularExpressionOptions.IgnoreMetacharacters
        public static var dotMatchesLineSeparators = NSRegularExpressionOptions.DotMatchesLineSeparators
        public static var anchorsMatchLines = NSRegularExpressionOptions.AnchorsMatchLines
        public static var useUnixLineSeparators = NSRegularExpressionOptions.UseUnixLineSeparators
        public static var useUnicodeWordBoundaries = NSRegularExpressionOptions.UseUnicodeWordBoundaries
    }
    
    public extension NSRegularExpression {
        public func matches(in string: String, options: NSMatchingOptions, range: NSRange) -> [NSTextCheckingResult] {
            return self.matchesInString(string, options: options, range: range)
        }
        
        public func firstMatch(in string: String, options: NSMatchingOptions, range: NSRange) -> NSTextCheckingResult? {
            return self.firstMatchInString(string, options: options, range: range)
        }
        
        public func replacementString(for result: NSTextCheckingResult, in string: String, offset: Int, template templ: String) -> String {
            return self.replacementStringForResult(result, inString: string, offset: offset, template: templ)
        }
        
        public func stringByReplacingMatches(in string: String, options: NSMatchingOptions, range: NSRange, withTemplate templ: String) -> String {
            return self.stringByReplacingMatchesInString(string, options: options, range: range, withTemplate: templ)
        }
    }
#endif

