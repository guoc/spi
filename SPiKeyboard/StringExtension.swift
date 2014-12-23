
import Foundation

let lowercaseLetterAndUnderScoreCharacterSet: NSCharacterSet = {
    var characterSet: NSMutableCharacterSet = NSCharacterSet.lowercaseLetterCharacterSet().mutableCopy() as NSMutableCharacterSet
    characterSet.addCharactersInString("_")
    return characterSet as NSCharacterSet
    }()

let lowercaseLetterAndSpaceCharacterSet: NSCharacterSet = {
    var characterSet: NSMutableCharacterSet = NSCharacterSet.lowercaseLetterCharacterSet().mutableCopy() as NSMutableCharacterSet
    characterSet.addCharactersInString(" ")
    return characterSet as NSCharacterSet
    }()

let lowercaseLetterAndUnderScoreAndSpaceCharacterSet: NSCharacterSet = {
    var characterSet: NSMutableCharacterSet = NSCharacterSet.lowercaseLetterCharacterSet().mutableCopy() as NSMutableCharacterSet
    characterSet.addCharactersInString(" _")
    return characterSet as NSCharacterSet
    }()

let whitespaceAndUnderscoreCharacterSet: NSCharacterSet = {
    var characterSet: NSMutableCharacterSet = NSCharacterSet.whitespaceCharacterSet().mutableCopy() as NSMutableCharacterSet
    characterSet.addCharactersInString("_")
    return characterSet as NSCharacterSet
    }()

let letterAndSpaceCharacterSet: NSCharacterSet = {
    var characterSet: NSMutableCharacterSet = NSCharacterSet.letterCharacterSet().mutableCopy() as NSMutableCharacterSet
    characterSet.addCharactersInString(" ")
    return characterSet as NSCharacterSet
    }()

extension String {
    func stringByRemovingCharactersInSet(characterSet: NSCharacterSet) -> String {
        return "".join(self.componentsSeparatedByCharactersInSet(characterSet))
    }
    
    func stringByRemovingWhitespace() -> String {
        return "".join(self.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))
    }
    
    func stringByRemovingWhitespaceAndUnderscore() -> String {
        return "".join(self.componentsSeparatedByCharactersInSet(whitespaceAndUnderscoreCharacterSet))
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
