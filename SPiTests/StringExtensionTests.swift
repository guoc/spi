
import UIKit
import XCTest

class StringExtensionTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testTestChineseType() {
        XCTAssertTrue("一".containsChinese())    // 0x4E00
        XCTAssertTrue("龥".containsChinese())    // 0x9FA5
        XCTAssertTrue("选".containsChinese())    // 0x9009
        XCTAssertFalse("a".containsChinese())
        XCTAssertFalse("1".containsChinese())
        XCTAssertFalse("$".containsChinese())
    }
    
    func testGetCandidateType() {
        XCTAssert("天天".getCandidateType() == CandidateType.chinese)
        XCTAssert("天@".getCandidateType() == CandidateType.special)
        XCTAssert("@天".getCandidateType() == CandidateType.special)
        XCTAssert("@e".getCandidateType() == CandidateType.special)
        XCTAssert("e@".getCandidateType() == CandidateType.special)
        XCTAssert("ea".getCandidateType() == CandidateType.english)
        XCTAssert("塔a".getCandidateType() == CandidateType.special)
        XCTAssert("o进".getCandidateType() == CandidateType.special)
    }

}
