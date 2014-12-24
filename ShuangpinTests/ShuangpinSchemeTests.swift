//
//  ShuangpinSchemeTests.swift
//  SPi
//
//  Created by GuoChen on 24/12/2014.
//  Copyright (c) 2014 guoc. All rights reserved.
//

import UIKit
import XCTest

let xiaoheScheme = ShuangpinSchemeTests.getScheme("小鹤双拼")!
let ziranmaScheme = ShuangpinSchemeTests.getScheme("自然码")!
let pinyinjiajiaScheme = ShuangpinSchemeTests.getScheme("拼音加加")!
let weiruanpinyin2003Scheme = ShuangpinSchemeTests.getScheme("微软拼音2003")!
let ziguangpinyinScheme = ShuangpinSchemeTests.getScheme("紫光拼音")!
let zhinengabcScheme = ShuangpinSchemeTests.getScheme("智能ABC")!

class ShuangpinSchemeTests: XCTestCase {
    
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
    
    func testShuangpinScheme() {
        println("Check XiaoHe ...")
        checkShuangpinScheme(xiaoheScheme)
        println("Check ZiRanMa ...")
        checkShuangpinScheme(ziranmaScheme)
        println("Check PinYinJiaJia ...")
        checkShuangpinScheme(pinyinjiajiaScheme)
        println("Check WeiRuanPinYin2003 ...")
        checkShuangpinScheme(weiruanpinyin2003Scheme)
        println("Check ZiGuangPinYin ...")
        checkShuangpinScheme(ziguangpinyinScheme)
        println("Check ZhiNengABC ...")
        checkShuangpinScheme(zhinengabcScheme)
    }
    
    class func getScheme(schemeName: String) -> [String: String]? {
        NSUserDefaults.standardUserDefaults().setObject(schemeName, forKey: "kScheme")
        let path = NSBundle(forClass: ShuangpinScheme.self).pathForResource(schemeName, ofType: "spscheme")
        var scheme: [String: String]!
        if NSFileManager.defaultManager().fileExistsAtPath(path!) {
            scheme = NSDictionary(contentsOfFile: path!) as [String: String]!
        } else {
            println("scheme is not found")
        }
        return scheme
    }
    
    func checkShuangpinScheme(scheme: [String: String]) {
        for (sourceShuangpin, targetShuangpin) in scheme {
            let sourceShengmu = String(sourceShuangpin[sourceShuangpin.startIndex])
            let targetShengmu = String(targetShuangpin[targetShuangpin.startIndex])
            if targetShuangpin.getReadingLength() >= 1 || targetShuangpin.getReadingLength() <= 2 {
                XCTAssert(scheme[sourceShengmu] == targetShengmu)
            } else {
                XCTFail()
            }
            if targetShuangpin.getReadingLength() == 2 {
                let sourceYunmu = String(sourceShuangpin[sourceShuangpin.startIndex.successor()])
                let targetYunmu = String(targetShuangpin[targetShuangpin.startIndex.successor()])
                if let yunmuS = YunmusAfterShengmu[targetShengmu] {
                    XCTAssert(contains(yunmuS, targetYunmu))
                } else {
                    XCTFail()
                }
            }
        }
    }

}
