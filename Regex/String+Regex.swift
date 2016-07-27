//===--- String+Regex.swift -----------------------------------------------===//
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

/**
 * Adds Regex extensions to the String.
 */
public extension String {
    /**
     * Creates a regex using this string as a pattern. Can return nil if pattern is invalid.
     */
    public var r : Regex? {
        get {
            return try? Regex(pattern: self)
        }
    }
    
    /**
     * An inverse alias to Regex.split
     * 
     
     - parameter regex: Regex to split the string with
     - returns: An array. See Regex.split for more details.
     */
    public func split(using regex:RegexType?) -> [String] {
        guard let regex = regex else {
            return [self]
        }
        return regex.split(self)
    }
}

infix operator =~ {associativity left precedence 140}
infix operator !~ {associativity left precedence 140}

/**
 * Sintactic sugar for pattern matching. Used as "ABC" =~ ".*".r
 * See Regex.matches for more details.
 *
 
 - parameter source: String to match.
 - parameter regex: Regex to match the string with.
 - returns: True if matches, false otherwise.
 */
public func =~(source:String, regex:RegexType?) -> Bool {
    guard let matches = regex?.matches(source) else {
        return false
    }
    return matches
}

/**
 * Sintactic sugar for pattern matching. Used as "ABC" =~ ".*"
 * See Regex.matches for more details.
 *
 * Regex is automaticall created from the second string.
 *
 
 - parameter source: String to match.
 - parameter regex: Pattern string to match the string with.
 - returns: True if matches, false otherwise.
 */
public func =~(source:String, pattern:String) -> Bool {
    return source =~ pattern.r
}

/**
 * Sintactic sugar for pattern matching. Used as "ABC" !~ ".*".r
 * See Regex.matches for more details.
 * Basically is negation of =~ operator.
 *
 
 - parameter source: String to match.
 - parameter regex: Regex to match the string with.
 - returns: False if matches, true otherwise.
 */
public func !~(source:String, regex:RegexType?) -> Bool {
    return !(source =~ regex)
}

/**
 * Sintactic sugar for pattern matching. Used as "ABC" =~ ".*"
 * See Regex.matches for more details.
 * Basically is negation of =~ operator.
 *
 * Regex is automaticall created from the second string.
 *
 
 - parameter source: String to match.
 - parameter regex: Pattern string to match the string with.
 - returns: False if matches, true otherwise.
 */
public func !~(source:String, pattern:String) -> Bool {
    return !(source =~ pattern.r)
}

/**
 * Operator is used by switch keyword in constructions like following:
 * switch str {
 *   case "\\d+".r: print("has digit")
 *   case "[a-z]+".r: print("has letter")
 *   default: print("nothing")
 * }
 *
 
 - returns: True if matches, false otherwise.
 */
public func ~=(regex:RegexType?, source:String) -> Bool {
    return source =~ regex
}