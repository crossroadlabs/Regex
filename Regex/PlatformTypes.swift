//===--- PlatformTypes.swift -----------------------------------------------===//
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

#if os(OSX)
    import CIcuRegex
    
    typealias CompiledMatchContext = CompiledPattern
    
    public enum RegexError : ErrorType {
        case CompilationError(errorCode: Int)
    }
    
    struct GroupRange {
        let location:Int
        let length:Int
    }
    
    struct CompiledPatternMatch {
        let ranges: [GroupRange]
        
        var numberOfRanges: Int {
            get {
                return ranges.count
            }
        }
        
        var range:GroupRange {
            get {
                return ranges[0]
            }
        }
        
        func rangeAtIndex(index: Int) -> GroupRange {
            return ranges[index]
        }
        
        static func fromIcuMatch(icuMatch: CompiledMatchContext) -> CompiledPatternMatch? {
            var ec = U_ZERO_ERROR
            let count = uregex_groupCount_56(icuMatch.icu, &ec) + 1
            guard ec == U_ZERO_ERROR else {
                return nil
            }
        
            var ranges = [GroupRange]()
            for index in 0..<count {
                let start = uregex_start_56(icuMatch.icu, Int32(index), &ec)
                guard ec == U_ZERO_ERROR else {
                    return nil
                }
                guard start >= 0 else {
                    ranges.append(GroupRange(location:Int.max, length:0))
                    continue
                }
                let end = uregex_end_56(icuMatch.icu, Int32(index), &ec)
                guard ec == U_ZERO_ERROR else {
                    return nil
                }
                guard end >= 0 else {
                    ranges.append(GroupRange(location:Int.max, length:0))
                    continue
                }
                ranges.append(GroupRange(location: Int(start), length: Int(end-start)))
            }
            return CompiledPatternMatch(ranges: ranges)
        }
        
    }
    
    class CompiledPattern {
        private let pattern: COpaquePointer
        private let text: ICUText
        
        init(icu: COpaquePointer, text: ICUText) {
            pattern = icu
            self.text = text
        }
        
        deinit {
            uregex_close_56(pattern)
        }
        
        var icu: COpaquePointer {
            get {
                return pattern
            }
        }
    }
    
    class ICUText {
        private var uText:UnsafeMutablePointer<UText> = nil
        private let buffer: UnsafeMutableBufferPointer<UInt8>
        
        private func destroyBuffer() {
            let buf = buffer.baseAddress
            buf.destroy()
            buf.dealloc(buffer.count)
        }
        
        required init(string: String) throws {
            var ec = U_ZERO_ERROR
            
            buffer = string.nulTerminatedUTF8.withUnsafeBufferPointer { (data) -> UnsafeMutableBufferPointer<UInt8> in
                let buffer = UnsafeMutablePointer<UInt8>.alloc(data.count)
                memcpy(buffer, data.baseAddress, data.count)
                return UnsafeMutableBufferPointer<UInt8>(start:buffer, count:data.count)
            }
            uText = utext_openUTF8_56(nil, UnsafePointer<Int8>(buffer.baseAddress), Int64(buffer.count-1), &ec)
            guard ec == U_ZERO_ERROR else {
                destroyBuffer()
                throw RegexError.CompilationError(errorCode: Int(ec.rawValue))
            }
        }
        
        init(icu: UnsafeMutablePointer<UText>) {
            uText = icu
            buffer = UnsafeMutableBufferPointer<UInt8>(start:nil, count: 0)
        }
        
        var icu:UnsafeMutablePointer<UText> {
            get {
                return uText
            }
        }
        
        func toString() throws -> String {
            var ec = U_ZERO_ERROR
            var size = utext_extract_56(uText, 0, Int64.max, nil, 0, &ec) + 1
            guard ec == U_ZERO_ERROR || ec == U_BUFFER_OVERFLOW_ERROR else {
                throw RegexError.CompilationError(errorCode: Int(ec.rawValue))
            }
            ec = U_ZERO_ERROR
            let bufSize = Int(size)
            let buf = UnsafeMutablePointer<UInt16>.alloc(bufSize)
            size = utext_extract_56(uText, 0, Int64(size), buf, size, &ec)
            guard ec == U_ZERO_ERROR else {
                throw RegexError.CompilationError(errorCode: Int(ec.rawValue))
            }
            let res = String(utf16CodeUnits: UnsafePointer(buf), count: Int(size))
            buf.destroy()
            buf.dealloc(bufSize)
            return res
        }
        
        deinit {
            if uText != nil {
                utext_close_56(uText)
            }
            destroyBuffer()
        }
    }
#else
    //here we use NSRegularExpression
    import Foundation
    
    typealias CompiledPattern = NSRegularExpression
    typealias CompiledMatchContext = [NSTextCheckingResult]
    typealias CompiledPatternMatch = NSTextCheckingResult
    typealias GroupRange = NSRange
#endif
