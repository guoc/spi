
import Foundation

let lowercaseLetterAndUnderScoreCharacterSet: CharacterSet = {
    var characterSet: NSMutableCharacterSet = (CharacterSet.lowercaseLetters as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
    characterSet.addCharacters(in: "_")
    return characterSet as CharacterSet
    }()

let lowercaseLetterAndSpaceCharacterSet: CharacterSet = {
    var characterSet: NSMutableCharacterSet = (CharacterSet.lowercaseLetters as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
    characterSet.addCharacters(in: " ")
    return characterSet as CharacterSet
    }()

let lowercaseLetterAndUnderScoreAndSpaceCharacterSet: CharacterSet = {
    var characterSet: NSMutableCharacterSet = (CharacterSet.lowercaseLetters as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
    characterSet.addCharacters(in: " _")
    return characterSet as CharacterSet
    }()

let whitespaceAndUnderscoreCharacterSet: CharacterSet = {
    var characterSet: NSMutableCharacterSet = (CharacterSet.whitespaces as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
    characterSet.addCharacters(in: "_")
    return characterSet as CharacterSet
    }()

let letterAndSpaceCharacterSet: CharacterSet = {
    var characterSet: NSMutableCharacterSet = (CharacterSet.letters as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
    characterSet.addCharacters(in: " ")
    return characterSet as CharacterSet
    }()

extension String {
    
    func containsChinese() -> Bool {
        let str: NSString = self as NSString
        for i in 0 ..< str.length {
            let a = str.character(at: i)
            if a >= 0x4E00 && a <= 0x9FA5 {
                return true
            }
        }
        return false
    }
    
    func getCandidateType() -> CandidateType {
        if self == "" {
            return .empty
        }
        var containsSpecial = false
        var containsChinese = false
        var containsEnglish = false
        var type: CandidateType = .english
        let str: NSString = self as NSString
        for i in 0 ..< str.length {
            let a = str.character(at: i)
            if a >= 0x4E00 && a <= 0x9FA5 {
                containsChinese = true
            } else if a < 0x41 || a > 0x7A {
                containsSpecial = true
            } else {
                containsEnglish = true
            }
        }
        if containsSpecial {
            type = .special
        } else {
            if containsChinese {
                if containsEnglish {
                    type = .special
                } else {
                    type = .chinese
                }
            } else {
                if containsEnglish {
                    type = .english
                } else {
                    assertionFailure("This string does not contain Chinese, English or Special")
                }
            }
        }
        return type
    }
    
    func stringByRemovingCharactersInSet(_ characterSet: CharacterSet) -> String {
        return self.components(separatedBy: characterSet).joined(separator: "")
    }
    
    func stringByRemovingWhitespace() -> String {
        return self.components(separatedBy: CharacterSet.whitespaces).joined(separator: "")
    }
    
    func stringByRemovingWhitespaceAndUnderscore() -> String {
        return self.components(separatedBy: whitespaceAndUnderscoreCharacterSet).joined(separator: "")
    }
    
    func onlyContainsLowercaseLetters() -> Bool {
        return self.stringByRemovingCharactersInSet(CharacterSet.lowercaseLetters) == ""
    }
    
    func containsUppercaseLetters() -> Bool {
        return self.rangeOfCharacter(from: CharacterSet.uppercaseLetters) != nil
    }
    
    func containsLetters() -> Bool {
        return self.rangeOfCharacter(from: CharacterSet.letters) != nil
    }
    
    func containsLettersOrUnderscore() -> Bool {
        return self.rangeOfCharacter(from: lowercaseLetterAndUnderScoreCharacterSet) != nil
    }
    
    func containsNonLettersOrSpace() -> Bool {
        return self.stringByRemovingCharactersInSet(letterAndSpaceCharacterSet) != ""
    }
    
    func containsNonLetters() -> Bool {
        return self.stringByRemovingCharactersInSet(CharacterSet.letters) != ""
    }
    
    func getReadingLength() -> Int {
        return self.lengthOfBytes(using: String.Encoding.utf32) / 4
    }
}
