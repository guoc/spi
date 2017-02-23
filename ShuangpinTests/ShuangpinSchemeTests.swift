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
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testShuangpinScheme() {
        print("Check XiaoHe ...")
        checkShuangpinScheme(xiaoheScheme)
        print("Check ZiRanMa ...")
        checkShuangpinScheme(ziranmaScheme)
        print("Check PinYinJiaJia ...")
        checkShuangpinScheme(pinyinjiajiaScheme)
        print("Check WeiRuanPinYin2003 ...")
        checkShuangpinScheme(weiruanpinyin2003Scheme)
        print("Check ZiGuangPinYin ...")
        checkShuangpinScheme(ziguangpinyinScheme)
        print("Check ZhiNengABC ...")
        checkShuangpinScheme(zhinengabcScheme)
    }
    
    class func getScheme(_ schemeName: String) -> [String: String]? {
        UserDefaults.standard.set(schemeName, forKey: "kScheme")
        let path = Bundle(for: ShuangpinScheme.self).path(forResource: schemeName, ofType: "spscheme")
        var scheme: [String: String]!
        if FileManager.default.fileExists(atPath: path!) {
            scheme = NSDictionary(contentsOfFile: path!) as! [String: String]!
        } else {
            print("scheme is not found")
        }
        return scheme
    }
    
    func checkShuangpinScheme(_ scheme: [String: String]) {
        for (sourceShuangpin, targetShuangpin) in scheme {
            let sourceShengmu = String(sourceShuangpin[sourceShuangpin.startIndex])
            let targetShengmu = String(targetShuangpin[targetShuangpin.startIndex])
            if targetShuangpin.getReadingLength() >= 1 && targetShuangpin.getReadingLength() <= 2 {
                XCTAssert(scheme[sourceShengmu] == targetShengmu)
            } else {
                XCTFail()
            }
            if targetShuangpin.getReadingLength() == 2 {
                _ = String(sourceShuangpin[sourceShuangpin.characters.index(after: sourceShuangpin.startIndex)])    // sourceYunmu
                let targetYunmu = String(targetShuangpin[targetShuangpin.characters.index(after: targetShuangpin.startIndex)])
                if let yunmuS = YunmusAfterShengmu[targetShengmu] {
                    XCTAssert(yunmuS.contains(targetYunmu))
                } else {
                    XCTFail()
                }
            }
        }
    }

}
