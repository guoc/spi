//
//  GetShengmu.swift
//  SPi
//
//  Created by GuoChen on 24/12/2014.
//  Copyright (c) 2014 guoc. All rights reserved.
//

import UIKit
import XCTest

class GetShengmu: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testGetShengmuFromFormalizedShuangpinString() {
        let failMessage = "Fail in testGetShengmuFromFormalizedShuangpinString"
        XCTAssert(getShengmuString(from: "") == "", failMessage)
        XCTAssert(getShengmuString(from: "a") == "a", failMessage)
        XCTAssert(getShengmuString(from: "ab") == "a", failMessage)
        XCTAssert(getShengmuString(from: "ab c") == "ac", failMessage)
        XCTAssert(getShengmuString(from: "ab cd") == "ac", failMessage)
    }

}
