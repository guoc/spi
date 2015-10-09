
import Foundation

let lowercaseLetterAndUnderScoreCharacterSet: NSCharacterSet = {
    var characterSet: NSMutableCharacterSet = NSCharacterSet.lowercaseLetterCharacterSet().mutableCopy() as! NSMutableCharacterSet
    characterSet.addCharactersInString("_")
    return characterSet as NSCharacterSet
    }()

let lowercaseLetterAndSpaceCharacterSet: NSCharacterSet = {
    var characterSet: NSMutableCharacterSet = NSCharacterSet.lowercaseLetterCharacterSet().mutableCopy() as! NSMutableCharacterSet
    characterSet.addCharactersInString(" ")
    return characterSet as NSCharacterSet
    }()

let lowercaseLetterAndUnderScoreAndSpaceCharacterSet: NSCharacterSet = {
    var characterSet: NSMutableCharacterSet = NSCharacterSet.lowercaseLetterCharacterSet().mutableCopy() as! NSMutableCharacterSet
    characterSet.addCharactersInString(" _")
    return characterSet as NSCharacterSet
    }()

let whitespaceAndUnderscoreCharacterSet: NSCharacterSet = {
    var characterSet: NSMutableCharacterSet = NSCharacterSet.whitespaceCharacterSet().mutableCopy() as! NSMutableCharacterSet
    characterSet.addCharactersInString("_")
    return characterSet as NSCharacterSet
    }()

let letterAndSpaceCharacterSet: NSCharacterSet = {
    var characterSet: NSMutableCharacterSet = NSCharacterSet.letterCharacterSet().mutableCopy() as! NSMutableCharacterSet
    characterSet.addCharactersInString(" ")
    return characterSet as NSCharacterSet
    }()

extension String {
    
    func containsChinese() -> Bool {
        let str: NSString = self
        for (var i = 0; i < str.length; i++) {
            let a = str.characterAtIndex(i)
            if a >= 0x4E00 && a <= 0x9FA5 {
                return true
            }
        }
        return false
    }
    
    func getCandidateType() -> CandidateType {
        if self == "" {
            return .Empty
        }
        var containsSpecial = false
        var containsChinese = false
        var containsEnglish = false
        var type: CandidateType = .English
        let str: NSString = self
        for (var i = 0; i < str.length; i++) {
            let a = str.characterAtIndex(i)
            if a >= 0x4E00 && a <= 0x9FA5 {
                containsChinese = true
            } else if a < 0x41 || a > 0x7A {
                containsSpecial = true
            } else {
                containsEnglish = true
            }
        }
        if containsSpecial {
            type = .Special
        } else {
            if containsChinese {
                if containsEnglish {
                    type = .Special
                } else {
                    type = .Chinese
                }
            } else {
                if containsEnglish {
                    type = .English
                } else {
                    assertionFailure("This string does not contain Chinese, English or Special")
                }
            }
        }
        return type
    }
    
    func stringByRemovingCharactersInSet(characterSet: NSCharacterSet) -> String {
        return self.componentsSeparatedByCharactersInSet(characterSet).joinWithSeparator("")
    }
    
    func stringByRemovingWhitespace() -> String {
        return self.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).joinWithSeparator("")
    }
    
    func stringByRemovingWhitespaceAndUnderscore() -> String {
        return self.componentsSeparatedByCharactersInSet(whitespaceAndUnderscoreCharacterSet).joinWithSeparator("")
    }
    
    func onlyContainsLowercaseLetters() -> Bool {
        return self.stringByRemovingCharactersInSet(NSCharacterSet.lowercaseLetterCharacterSet()) == ""
    }
    
    func containsUppercaseLetters() -> Bool {
        return self.rangeOfCharacterFromSet(NSCharacterSet.uppercaseLetterCharacterSet()) != nil
    }
    
    func containsLetters() -> Bool {
        return self.rangeOfCharacterFromSet(NSCharacterSet.letterCharacterSet()) != nil
    }
    
    func containsLettersOrUnderscore() -> Bool {
        return self.rangeOfCharacterFromSet(lowercaseLetterAndUnderScoreCharacterSet) != nil
    }
    
    func containsNonLettersOrSpace() -> Bool {
        return self.stringByRemovingCharactersInSet(letterAndSpaceCharacterSet) != ""
    }
    
    func containsNonLetters() -> Bool {
        return self.stringByRemovingCharactersInSet(NSCharacterSet.letterCharacterSet()) != ""
    }
    
    func getReadingLength() -> Int {
        return self.lengthOfBytesUsingEncoding(NSUTF32StringEncoding) / 4
    }
}
