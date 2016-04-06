//===--- NSRegularExpression3.swift ----------------------------------------===//
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

