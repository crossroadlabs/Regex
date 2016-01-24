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
    let regex:RegexType = try! Regex(pattern:RegexTests.pattern, groupNames:"letter", "digits", "rest")
    let source = "l321321alala"
    let letter = "l"
    let digits = "321321"
    let rest = "alala"
    let replaceAllTemplate = "$1-$2-$3"
    let replaceAllResult = "l-321321-alala"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSimple() {
        XCTAssertEqual(RegexTests.pattern.r?.findFirst(source)?.group(2), digits)
    }
    
    func testGroup(group:String, reference:String) {
        let matches = regex.findAll(source)
        for match in matches {
            let value = match.group(group)
            XCTAssertEqual(value, reference)
        }
    }
    
    func testLetter() {
        testGroup("letter", reference: letter)
    }
    
    func testDigits() {
        testGroup("digits", reference: digits)
    }
    
    func testRest() {
        testGroup("rest", reference: rest)
    }
    
    func testFirstMatch() {
        let match = regex.findFirst(source)
        XCTAssertNotNil(match)
        if let match = match {
            XCTAssertEqual(letter, match.group("letter"))
            XCTAssertEqual(digits, match.group("digits"))
            XCTAssertEqual(rest, match.group("rest"))
            
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
        let replaced = regex.replaceAll(source, replacement: replaceAllTemplate)
        XCTAssertEqual(replaceAllResult, replaced)
    }
    
    func testReplaceAllWithReplacer() {
        let replaced = "(.+?)([1,2,3]+)(.+?)".r?.replaceAll("l321321la321a") { match in
            if match.group(1) == "l" {
                return nil
            } else {
                return match.matched.uppercaseString
            }
        }
        XCTAssertEqual("l321321lA321A", replaced)
    }
    
    func testReplaceFirst() {
        let replaced = "(.+?)([1,2,3]+)(.+?)".r?.replaceFirst("l321321la321a", replacement: "$1-$2-$3-")
        XCTAssertEqual("l-321321-l-a321a", replaced)
    }
    
    func testReplaceFirstWithReplacer() {
        let replaced1 = "(.+?)([1,2,3]+)(.+?)".r?.replaceFirst("l321321la321a") { match in
            return match.matched.uppercaseString
        }
        XCTAssertEqual("L321321La321a", replaced1)
        
        let replaced2 = "(.+?)([1,2,3]+)(.+?)".r?.replaceFirst("l321321la321a") { match in
            return nil
        }
        XCTAssertEqual("l321321la321a", replaced2)
    }
    
    func testSplit() {
        let names = "Harry Trump ;Fred Barney; Helen Rigby ; Bill Abel ;Chris Hand";
        let re = "\\s*;\\s*".r!;
        let nameList = re.split(names);
        XCTAssertEqual(nameList, ["Harry Trump", "Fred Barney", "Helen Rigby", "Bill Abel", "Chris Hand"])
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
