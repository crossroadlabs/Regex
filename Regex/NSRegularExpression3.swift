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

#if swift(>=3.0)
#else
    extension NSRegularExpressionOptions {
        static var caseInsensitive = NSRegularExpressionOptions.CaseInsensitive
        static var allowCommentsAndWhitespace = NSRegularExpressionOptions.AllowCommentsAndWhitespace
        static var ignoreMetacharacters = NSRegularExpressionOptions.IgnoreMetacharacters
        static var dotMatchesLineSeparators = NSRegularExpressionOptions.DotMatchesLineSeparators
        static var anchorsMatchLines = NSRegularExpressionOptions.AnchorsMatchLines
        static var useUnixLineSeparators = NSRegularExpressionOptions.UseUnixLineSeparators
        static var useUnicodeWordBoundaries = NSRegularExpressionOptions.UseUnicodeWordBoundaries
    }
    
    extension NSRegularExpression {
        func matches(in string: String, options: NSMatchingOptions, range: NSRange) -> [NSTextCheckingResult] {
            return self.matchesInString(string, options: options, range: range)
        }
        
        func firstMatch(in string: String, options: NSMatchingOptions, range: NSRange) -> NSTextCheckingResult? {
            return self.firstMatchInString(string, options: options, range: range)
        }
        
        func replacementString(for result: NSTextCheckingResult, in string: String, offset: Int, template templ: String) -> String {
            return self.replacementStringForResult(result, inString: string, offset: offset, template: templ)
        }
        
        func stringByReplacingMatches(in string: String, options: NSMatchingOptions, range: NSRange, withTemplate templ: String) -> String {
            return self.stringByReplacingMatchesInString(string, options: options, range: range, withTemplate: templ)
        }
    }
#endif

#if swift(>=3.0) && !os(Linux)
#else
    extension NSRegularExpression {
        typealias Options = NSRegularExpressionOptions
        typealias MatchingOptions = NSMatchingOptions
    }

    typealias RegularExpression = NSRegularExpression
    typealias TextCheckingResult = NSTextCheckingResult
#endif

