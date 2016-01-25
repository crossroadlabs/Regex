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

//TODO: implement replace
//TODO: implement split
//TODO: implement with PCRE
//TODO: implement sintactic sugar operators

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

// later make OS X to work via pcre as well (should be faster)
#if os(Linux) || os(OSX)
    import Foundation
    import pcre
    
    public class RegexMatch {

        private var ranges: [Range<Int>?]
        
        private init(ovector: UnsafeMutablePointer<Int32>, matches: Int32) {

            ranges = []
            for var i: Int = 0; i < Int(matches); i++ {
                let start = Int(ovector[i*2])
                let end = Int(ovector[i*2+1])
                if start < 0 || end < 0 {
                    ranges.append(nil)
                } else {
                    ranges.append(Range(start: start, end: end))
                }
            }
        }
        public var range: Range<Int> {
            return  ranges[0]!
        }
        public var numberOfRanges: Int {
            return ranges.count
        }
        public  func rangeAtIndex(index:Int) -> Range<Int>{
            return ranges[index]!
        }
    }
    
    typealias CompiledPattern = COpaquePointer
    typealias CompiledMatchContext = [RegexMatch]
    typealias CompiledPatternMatch = RegexMatch
    
    
    
    public enum RegexError: ErrorType {
        case Message(String)
        
        case NOMATCH
        case NULL
        case BADOPTION
        case BADMAGIC
        case UNKNOWN_OPCODE
        case UNKNOWN_NODE
        case NOMEMORY
        case NOSUBSTRING
        case MATCHLIMIT
        case CALLOUT
        case BADUTF8
        case BADUTF16
        case BADUTF32
        case BADUTF8_OFFSET
        case BADUTF16_OFFSET
        case PARTIAL
        case BADPARTIAL
        case INTERNAL
        case BADCOUNT
        case DFA_UITEM
        case DFA_UCOND
        case DFA_UMLIMIT
        case DFA_WSSIZE
        case DFA_RECURSE
        case RECURSIONLIMIT
        case NULLWSLIMIT
        case BADNEWLINE
        case BADOFFSET
        case SHORTUTF8
        case SHORTUTF16
        case RECURSELOOP
        case JIT_STACKLIMIT
        case BADMODE
        case BADENDIANNESS
        case DFA_BADRESTART
        case JIT_BADOPTION
        case BADLENGTH
        case UNSET
        
        public static func fromError(value: Int32) -> RegexError {
            switch value {
            case PCRE_ERROR_NOMATCH: return .NOMATCH
            case PCRE_ERROR_NULL: return .NULL
            case PCRE_ERROR_BADOPTION: return .BADOPTION
            case PCRE_ERROR_BADMAGIC: return .BADMAGIC
            case PCRE_ERROR_UNKNOWN_OPCODE: return .UNKNOWN_OPCODE
            case PCRE_ERROR_UNKNOWN_NODE: return .UNKNOWN_NODE
            case PCRE_ERROR_NOMEMORY: return .NOMEMORY
            case PCRE_ERROR_NOSUBSTRING: return .NOSUBSTRING
            case PCRE_ERROR_MATCHLIMIT: return .MATCHLIMIT
            case PCRE_ERROR_CALLOUT: return .CALLOUT
            case PCRE_ERROR_BADUTF8: return .BADUTF8
            case PCRE_ERROR_BADUTF16: return .BADUTF16
            case PCRE_ERROR_BADUTF32: return .BADUTF32
            case PCRE_ERROR_BADUTF8_OFFSET: return .BADUTF8_OFFSET
            case PCRE_ERROR_BADUTF16_OFFSET: return .BADUTF16_OFFSET
            case PCRE_ERROR_PARTIAL: return .PARTIAL
            case PCRE_ERROR_BADPARTIAL: return .BADPARTIAL
            case PCRE_ERROR_INTERNAL: return .INTERNAL
            case PCRE_ERROR_BADCOUNT: return .BADCOUNT
            case PCRE_ERROR_DFA_UITEM: return .DFA_UITEM
            case PCRE_ERROR_DFA_UCOND: return .DFA_UCOND
            case PCRE_ERROR_DFA_UMLIMIT: return .DFA_UMLIMIT
            case PCRE_ERROR_DFA_WSSIZE: return .DFA_WSSIZE
            case PCRE_ERROR_DFA_RECURSE: return .DFA_RECURSE
            case PCRE_ERROR_RECURSIONLIMIT: return .RECURSIONLIMIT
            case PCRE_ERROR_NULLWSLIMIT: return .NULLWSLIMIT
            case PCRE_ERROR_BADNEWLINE: return .BADNEWLINE
            case PCRE_ERROR_BADOFFSET: return .BADOFFSET
            case PCRE_ERROR_SHORTUTF8: return .SHORTUTF8
            case PCRE_ERROR_SHORTUTF16: return .SHORTUTF16
            case PCRE_ERROR_RECURSELOOP: return .RECURSELOOP
            case PCRE_ERROR_JIT_STACKLIMIT: return .JIT_STACKLIMIT
            case PCRE_ERROR_BADMODE: return .BADMODE
            case PCRE_ERROR_BADENDIANNESS: return .BADENDIANNESS
            case PCRE_ERROR_DFA_BADRESTART: return .DFA_BADRESTART
            case PCRE_ERROR_JIT_BADOPTION: return .JIT_BADOPTION
            case PCRE_ERROR_BADLENGTH: return .BADLENGTH
            case PCRE_ERROR_UNSET: return .UNSET
            default:
                return .Message("unknown PCRE error \(value)")
            }
        }
    }
    
    public struct RegexOptions: OptionSetType {
        public let rawValue: Int32
        public init(rawValue: Int32) { self.rawValue = rawValue }
        
        public static let None = RegexOptions(rawValue: 0)
        
        public static let ANCHORED = RegexOptions(rawValue: pcre.PCRE_ANCHORED)
        public static let AUTO_CALLOUT = RegexOptions(rawValue: pcre.PCRE_AUTO_CALLOUT)
        public static let BSR_ANYCRLF = RegexOptions(rawValue: pcre.PCRE_BSR_ANYCRLF)
        public static let BSR_UNICODE = RegexOptions(rawValue: pcre.PCRE_BSR_UNICODE)
        public static let CASELESS = RegexOptions(rawValue: pcre.PCRE_CASELESS)
        public static let DOLLAR_ENDONLY = RegexOptions(rawValue: pcre.PCRE_DOLLAR_ENDONLY)
        public static let DOTALL = RegexOptions(rawValue: pcre.PCRE_DOTALL)
        public static let DUPNAMES = RegexOptions(rawValue: pcre.PCRE_DUPNAMES)
        public static let EXTENDED = RegexOptions(rawValue: pcre.PCRE_EXTENDED)
        public static let EXTRA = RegexOptions(rawValue: pcre.PCRE_EXTRA)
        public static let FIRSTLINE = RegexOptions(rawValue: pcre.PCRE_FIRSTLINE)
        public static let JAVASCRIPT_COMPAT = RegexOptions(rawValue: pcre.PCRE_JAVASCRIPT_COMPAT)
        public static let MULTILINE = RegexOptions(rawValue: pcre.PCRE_MULTILINE)
        public static let NEVER_UTF = RegexOptions(rawValue: pcre.PCRE_NEVER_UTF)
        public static let NEWLINE_ANY = RegexOptions(rawValue: pcre.PCRE_NEWLINE_ANY)
        public static let NEWLINE_ANYCRLF = RegexOptions(rawValue: pcre.PCRE_NEWLINE_ANYCRLF)
        public static let NEWLINE_CR = RegexOptions(rawValue: pcre.PCRE_NEWLINE_CR)
        public static let NEWLINE_CRLF = RegexOptions(rawValue: pcre.PCRE_NEWLINE_CRLF)
        public static let NEWLINE_LF = RegexOptions(rawValue: pcre.PCRE_NEWLINE_LF)
        public static let NO_AUTO_CAPTURE = RegexOptions(rawValue: pcre.PCRE_NO_AUTO_CAPTURE)
        public static let NO_AUTO_POSSESS = RegexOptions(rawValue: pcre.PCRE_NO_AUTO_POSSESS)
        public static let NO_START_OPTIMIZE = RegexOptions(rawValue: pcre.PCRE_NO_START_OPTIMIZE)
        public static let NO_UTF16_CHECK = RegexOptions(rawValue: pcre.PCRE_NO_UTF16_CHECK)
        public static let NO_UTF32_CHECK = RegexOptions(rawValue: pcre.PCRE_NO_UTF32_CHECK)
        public static let NO_UTF8_CHECK = RegexOptions(rawValue: pcre.PCRE_NO_UTF8_CHECK)
        public static let UCP = RegexOptions(rawValue: pcre.PCRE_UCP)
        public static let UNGREEDY = RegexOptions(rawValue: pcre.PCRE_UNGREEDY)
        public static let UTF16 = RegexOptions(rawValue: pcre.PCRE_UTF16)
        public static let UTF32 = RegexOptions(rawValue: pcre.PCRE_UTF32)
        public static let UTF8 = RegexOptions(rawValue: pcre.PCRE_UTF8)
        
        // Specific to pcre_exec()
        public static let NOTBOL = RegexOptions(rawValue: pcre.PCRE_NOTBOL)
        public static let NOTEOL = RegexOptions(rawValue: pcre.PCRE_NOTEOL)
        public static let NOTEMPTY = RegexOptions(rawValue: pcre.PCRE_NOTEMPTY)
        public static let NOTEMPTY_ATSTART = RegexOptions(rawValue: pcre.PCRE_NOTEMPTY_ATSTART)
        public static let PARTIAL = RegexOptions(rawValue: pcre.PCRE_PARTIAL)
        public static let PARTIAL_SOFT = RegexOptions(rawValue: pcre.PCRE_PARTIAL_SOFT)
        public static let PARTIAL_HARD = RegexOptions(rawValue: pcre.PCRE_PARTIAL_HARD)
    }
    
    public func | (a: RegexOptions, b: RegexOptions) -> RegexOptions {
        return a.union(b)
    }
    
    public func & (a: RegexOptions, b: RegexOptions) -> RegexOptions {
        return a.intersect(b)
    }

    
    
#else
    //here we use NSRegularExpression
    import Foundation
    
    typealias CompiledPattern = COpaquePointer
    typealias CompiledMatchContext = [NSTextCheckingResult]
    typealias CompiledPatternMatch = NSTextCheckingResult
#endif

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
    
#if os(Linux) || os(OSX)
    
    private static func compile(pattern:String) throws -> CompiledPattern {
        let pcreErrorStr = UnsafeMutablePointer<UnsafePointer<Int8>>.alloc(1) //const char *pcreErrorStr;
        let pcreErrorOffset = UnsafeMutablePointer<Int32>.alloc(1) //int pcreErrorOffset;
        //char *aStrRegex;
        //
        //
        
        //let aStrRegex = "(\\\\.)|([\\/.])?(?:(?:\\:(\\w+)(?:\\(((?:\\\\.|[^()])+)\\))?|\\(((?:\\\\.|[^()])+)\\))([+*?])?|(\\*))"
        let utf8Pattern = pattern.cStringUsingEncoding(NSUTF8StringEncoding)!
        let res = pcre_compile(utf8Pattern, PCRE_CASELESS, pcreErrorStr, pcreErrorOffset, nil)
        
        print("res:", res.debugDescription)
        print("pcreErrorStr:", pcreErrorStr)
        print("pcreErrorOffset:", pcreErrorOffset)
        return res
    }
    
    
//    public func findAll1(text: String, count: Int = Int.max, options: RegexOptions = RegexOptions.None) throws -> [RegexMatch] {
//        guard let utf8Text = text.cStringUsingEncoding(NSUTF8StringEncoding) else { throw RegexError.BADUTF8 }
//        let utf8Length = Int32(utf8Text.count) - 1 // Ignore \0
//        var out: [RegexMatch] = []
//        var offset: Int32 = 0
//        let ovector = UnsafeMutablePointer<Int32>.alloc(3 * 32)
//        var n = 0
//        defer { ovector.destroy() }
//        while true {
//            let matches = pcre_exec(re, nil, utf8Text, utf8Length, offset, options.rawValue, ovector, 3 * 32)
//            if matches < 0 {
//                if matches == PCRE_ERROR_NOMATCH {
//                    break
//                }
//                throw RegexError.fromError(matches)
//            }
//            out.append(RegexMatch(re: self, string: text, ovector: ovector, matches: matches))
//            offset = ovector[Int(matches-1)*2+1]
//            if ++n >= count {
//                break
//            }
//        }
//        return out
//    }
    
    
    public func findAll(source:String) -> MatchSequence {
        
        guard let utf8Text = source.cStringUsingEncoding(NSUTF8StringEncoding) else {
            return MatchSequence(source: source, context: [], groupNames:[String]())
        }
        guard let re = compiled else {
            return MatchSequence(source: source, context: [], groupNames:[String]())
        }
        let utf8Length = Int32(utf8Text.count) - 1 // Ignore \0
        var offset: Int32 = 0
        let ovector = UnsafeMutablePointer<Int32>.alloc(3 * 32)
        defer { ovector.destroy() }
        let options = RegexOptions.None
        var match = [RegexMatch]()
        while true {
            let matches = pcre_exec(re, nil, utf8Text, utf8Length, offset, options.rawValue, ovector, 3 * 32)
            if matches < 0 {
                if matches == PCRE_ERROR_NOMATCH {
                    break
                }
                break
                //throw RegexError.fromError(matches)
            }
            match.append(RegexMatch(ovector: ovector, matches: matches))
            offset = ovector[Int(matches-1)*2+1]
        }
        return MatchSequence(source: source, context: match, groupNames:[String]())        // throw NSFoundationNotImplemented
    }
    public func findFirst(source:String) -> Match? {
        
        guard let utf8Text = source.cStringUsingEncoding(NSUTF8StringEncoding) else {
            return nil
        }
        guard let re = compiled else {
            return nil
        }
        let utf8Length = Int32(utf8Text.count) - 1 // Ignore \0
        let offset: Int32 = 0
        let ovector = UnsafeMutablePointer<Int32>.alloc(3 * 32)
        defer { ovector.destroy() }
        
        let options = RegexOptions.None
        
        let matches = pcre_exec(re, nil, utf8Text, utf8Length, offset, options.rawValue, ovector, 3 * 32)
        if matches <= 0 {
            return nil
        }
        let match = RegexMatch(ovector: ovector, matches: matches)

        return Match(source: source, match: match, groupNames: groupNames)
        
    }

    public func replaceAll(source:String, replacement:String) -> String {
        return source
    }
    
    public func replaceFirst(source:String, replacement:String) -> String {
        //return repl
//        return replaceFirst(source) { match in
//            self.compiled!.replacementStringForResult(match.match, inString: source, offset: 0, template: replacement)
//        }
        return source
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
            result.appendContentsOf(match.subgroups)
        }
        let rest = source.substringFromIndex(lastRange.endIndex)
        result.append(rest)
        return result
    }
}