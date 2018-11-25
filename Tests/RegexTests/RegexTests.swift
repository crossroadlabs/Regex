//===--- RegexTests.swift -------------------------------------------------===//
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

import XCTest
@testable import Regex

class RegexTests: XCTestCase {
    static let pattern:String = "(.+?)([1,2,3]*)(.*)"
    let regex:RegexProtocol = try! Regex(pattern:RegexTests.pattern, groupNames:"letter", "digits", "rest")
    let source = "l321321alala"
    let letter = "l"
    let digits = "321321"
    let rest = "alala"
    let replaceAllTemplate = "$1-$2-$3"
    let replaceAllResult = "l-321321-alala"
    
    let names = "Harry Trump ;Fred Barney; Helen Rigby ; Bill Abel ;Chris Hand"
    let namesSplitPattern = "\\s*;\\s*";
    let splitNames = ["Harry Trump", "Fred Barney", "Helen Rigby", "Bill Abel", "Chris Hand"]
    
    func testMatches() {
        XCTAssert(regex.matches(source))
        XCTAssert(source =~ regex)
        XCTAssert(source =~ RegexTests.pattern)
        
        XCTAssertFalse(source !~ regex)
        XCTAssertFalse(source !~ RegexTests.pattern)
    }
    
    func testSwitch() {
        let exp1 = self.expectation(description: "alpha works")
        switch letter {
            case "\\d".r: XCTFail("letter should not match a digit")
            case "[a-z]".r: exp1.fulfill()
            default: XCTFail("letter should have matched alpha")
        }
        
        let exp2 = self.expectation(description: "alpha works")
        switch digits {
            case "[a-z]+".r: XCTFail("digits should not match letters")
            case "[A-Z]+".r: XCTFail("digits should not match capital letters")
            default: exp2.fulfill()
        }
        
        self.waitForExpectations(timeout: 0, handler: nil)
    }
    
    func testSimple() {
        XCTAssertEqual(RegexTests.pattern.r?.findFirst(in: source)?.group(at: 2), digits)
    }
    
    func _test(group name:String, reference:String) {
        let matches = regex.findAll(in: source)
        for match in matches {
            let value = match.group(named: name)
            XCTAssertEqual(value, reference)
        }
    }
    
    func testLetter() {
        _test(group: "letter", reference: letter)
    }
    
    func testDigits() {
        _test(group: "digits", reference: digits)
    }
    
    func testRest() {
        _test(group: "rest", reference: rest)
    }
    
    func testFirstMatch() {
        let match = regex.findFirst(in: source)
        XCTAssertNotNil(match)
        if let match = match {
            XCTAssertEqual(letter, match.group(named: "letter"))
            XCTAssertEqual(digits, match.group(named: "digits"))
            XCTAssertEqual(rest, match.group(named: "rest"))
            
            XCTAssertEqual(source, match.matched)
            
            let subgroups = match.subgroups
            
            XCTAssertEqual(letter, subgroups[0])
            XCTAssertEqual(digits, subgroups[1])
            XCTAssertEqual(rest, subgroups[2])
        } else {
            XCTFail("Bad test, can not reach this path")
        }
    }
    
    func testReplaceAll() {
        let replaced = regex.replaceAll(in: source, with: replaceAllTemplate)
        XCTAssertEqual(replaceAllResult, replaced)
    }
    
    func testReplaceAllWithReplacer() {
        let replaced = "(.+?)([1,2,3]+)(.+?)".r?.replaceAll(in: "l321321la321a") { match in
            if match.group(at: 1) == "l" {
                return nil
            } else {
                return match.matched.uppercased()
            }
        }
        XCTAssertEqual("l321321lA321A", replaced)
    }
    
    func testReplaceFirst() {
        let replaced = "(.+?)([1,2,3]+)(.+?)".r?.replaceFirst(in: "l321321la321a", with: "$1-$2-$3-")
        XCTAssertEqual("l-321321-l-a321a", replaced)
    }
    
    func testReplaceFirstWithReplacer() {
        let replaced1 = "(.+?)([1,2,3]+)(.+?)".r?.replaceFirst(in: "l321321la321a") { match in
            return match.matched.uppercased()
        }
        XCTAssertEqual("L321321La321a", replaced1)
        
        let replaced2 = "(.+?)([1,2,3]+)(.+?)".r?.replaceFirst(in: "l321321la321a") { match in
            return nil
        }
        XCTAssertEqual("l321321la321a", replaced2)
    }

    func testGraphemeClusters() {
        let testString = """
            👍👍 Find me. 👌👨‍👩‍👧👨\u{200D}👩\u{200D}👧👌
            """
        let regex = try! Regex(pattern: "^(👍+) *([^👌]+?) *([👌👨‍👩‍👧]+)$",
                               options: [.anchorsMatchLines, .useUnicodeWordBoundaries],
                               groupNames: [])

        guard let firstMatch = regex.findFirst(in: testString) else {
            return XCTFail("Failed to find first match using anchored regex.")
        }

        XCTAssert(firstMatch.group(at: 1) == "👍👍",
                  "Incorrect first capture group for anchored regex.")
        XCTAssert(firstMatch.group(at: 2) == "Find me.",
                  "Incorrect second capture group for anchored regex.")
        XCTAssert(firstMatch.group(at: 3) == "👌👨‍👩‍👧👨‍👩‍👧👌",
                  "Incorrect third capture group for anchored regex.")

        let englishMatchSequence = regex.findAll(in: testString)
        XCTAssert(englishMatchSequence.context.count == 1,
                  "Failed to find match using anchored regex.")

        let englishFirstMatch = englishMatchSequence.makeIterator().next()!
        XCTAssert(englishFirstMatch.group(at: 1) == "👍👍",
                  "Incorrect first capture group for anchored regex.")
        XCTAssert(englishFirstMatch.group(at: 2) == "Find me.",
                  "Incorrect second capture group for anchored regex.")
        XCTAssert(englishFirstMatch.group(at: 3) == "👌👨‍👩‍👧👨‍👩‍👧👌",
                  "Incorrect third capture group for anchored regex.")


        let familyEmojiRegex = try! Regex(pattern: "👌([👨‍👩‍👧]+)",
                                          options: [.default],
                                          groupNames: [])
        guard let familyFirstMatch = familyEmojiRegex.findFirst(in: testString) else {
            return XCTFail("Failed to find first match using family regex.")
        }
        XCTAssert(familyFirstMatch.matched == "👌👨‍👩‍👧👨‍👩‍👧",
                  "Incorrect matched string for family emoji regex.")
        XCTAssert(familyFirstMatch.group(at: 1) == "👨‍👩‍👧👨‍👩‍👧",
                  "Incorrect first capture group for family emoji regex.")


        let testInArabic = "اختبار"
        let arabicTestString = "🇦🇪 مرحبًا ، هذا اختبار"
        let arabicRegex = try! Regex(pattern: testInArabic, groupNames: [])
        let arabicMatchSequence = arabicRegex.findAll(in: arabicTestString)
        XCTAssert(arabicMatchSequence.context.count == 1, "Failed to find match in Arabic test string.")
        let arabicFirstMatch = arabicMatchSequence.makeIterator().next()!
        XCTAssert(arabicFirstMatch.matched == testInArabic, "Failed to match Arabic.")


        let testInThai = "ทดสอบ"
        let thaiTestString = "🇹🇭 สวัสดีนี่เป็นแบบทดสอบ"
        let thaiRegex = try! Regex(pattern: testInThai, groupNames: [])
        let thaiMatchSequence = thaiRegex.findAll(in: thaiTestString)
        XCTAssert(thaiMatchSequence.context.count == 1, "Failed to find match in Thai test string.")
        let thaiFirstMatch = thaiMatchSequence.makeIterator().next()!
        XCTAssert(thaiFirstMatch.matched == testInThai, "Failed to match Thai.")
    }
    
    func testSplit() {
        let re = namesSplitPattern.r!
        let nameList = re.split(names)
        XCTAssertEqual(nameList, splitNames)
    }
    
    func testSplitOnString() {
        let nameList = names.split(using: namesSplitPattern.r)
        XCTAssertEqual(nameList, splitNames)
    }
    
    func testSplitWithSubgroups() {
        let myString = "Hello 1 word. Sentence number 2."
        let splits = myString.split(using: "(\\d)".r)
        XCTAssertEqual(splits, ["Hello ", "1", " word. Sentence number ", "2", "."])
    }
    
    func testNonExistingGroup() {
        let PATH_REGEXP = [
            // Match escaped characters that would otherwise appear in future matches.
            // This allows the user to escape special characters that won't transform.
            "(\\\\.)",
            // Match Express-style parameters and un-named parameters with a prefix
            // and optional suffixes. Matches appear as:
            //
            // "/:test(\\d+)?" => ["/", "test", "\d+", undefined, "?", undefined]
            // "/route(\\d+)"  => [undefined, undefined, undefined, "\d+", undefined, undefined]
            // "/*"            => ["/", undefined, undefined, undefined, undefined, "*"]
            "([\\/.])?(?:(?:\\:(\\w+)(?:\\(((?:\\\\.|[^()])+)\\))?|\\(((?:\\\\.|[^()])+)\\))([+*?])?|(\\*))"
            ].joined(separator: "|").r!
        
        let match = PATH_REGEXP.findFirst(in: "/:test(\\d+)?")!
        
        XCTAssertNil(match.group(at: 1))
        XCTAssertNotNil(match.group(at: 2))
    }
    
    func testSubscriptAccess() {
        let match = regex.findFirst(in: source)
        XCTAssertNotNil(match)
        if let match = match {
            let groups = match.groups
            XCTAssertEqual(letter, groups["letter"])
            XCTAssertEqual(digits, groups["digits"])
            XCTAssertEqual(rest, groups["rest"])
            XCTAssertNil(groups["unexisted"])
            
            XCTAssertEqual(source, groups[0])
            XCTAssertEqual(letter, groups[1])
            XCTAssertEqual(digits, groups[2])
            XCTAssertEqual(rest, groups[3])
            XCTAssertNil(groups[4])
        } else {
            XCTFail("Bad test, can not reach this path")
        }
    }
}

#if os(Linux)
extension RegexTests {
	static var allTests : [(String, (RegexTests) -> () throws -> Void)] {
		return [
			("testMatches", testMatches),
			("testSwitch", testSwitch),
			("testSimple", testSimple),
			("testLetter", testLetter),
			("testDigits", testDigits),
			("testRest", testRest),
			("testFirstMatch", testFirstMatch),
			("testReplaceAll", testReplaceAll),
			("testReplaceAllWithReplacer", testReplaceAllWithReplacer),
			("testReplaceFirst", testReplaceFirst),
			("testReplaceFirstWithReplacer", testReplaceFirstWithReplacer),
			("testSplit", testSplit),
			("testSplitOnString", testSplitOnString),
			("testSplitWithSubgroups", testSplitWithSubgroups),
			("testNonExistingGroup", testNonExistingGroup),
			("testSubscriptAccess", testSubscriptAccess)
		]
	}
}
#endif
