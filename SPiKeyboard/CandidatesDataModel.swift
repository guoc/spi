import UIKit

let textChecker = UITextChecker()

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

enum FormalizedTypingStringType {
    case Empty, EnglishOrShuangpin, English, Special
}

class FormalizedTypingString {
    
    let type: FormalizedTypingStringType
    let string: String
    
    init() {
        self.type = .Empty
        self.string = ""
    }
    
    init(type: FormalizedTypingStringType, string: String) {
        self.type = type
        self.string = string
    }
}

class TypingString {
    
    var _formalizedTypingStringForQuery: FormalizedTypingString? = nil
    var _displayedString: String? = nil
    
    var userTypingString: String {
        didSet {
            _formalizedTypingStringForQuery = nil
            _displayedString = nil
        }
    }
    
    var displayedString: String {
        get {
            if _displayedString == nil {
                _displayedString = getFormalizedTypingString(userTypingString, byScheme: ShuangpinScheme.getScheme(), forDisplay: true).string
            }
            return _displayedString!
        }
    }
    
    var formalizedTypingStringForQuery: FormalizedTypingString {
        get {
            if _formalizedTypingStringForQuery == nil {
                _formalizedTypingStringForQuery = getFormalizedTypingString(userTypingString, byScheme: ShuangpinScheme.getScheme(), forDisplay: false)
            }
            return _formalizedTypingStringForQuery!
        }
    }
    
    var type: FormalizedTypingStringType {
        get {
            return self.formalizedTypingStringForQuery.type
        }
    }
    
    init() {
        userTypingString = ""
    }
    
    init(userTypingString: String) {
        self.userTypingString = userTypingString
    }
    
    func reset() {
        userTypingString = ""
        _formalizedTypingStringForQuery = nil
        _displayedString = nil
    }
    
    func append(newString: String) {
        userTypingString += newString
    }
    
    func deleteLast() {
        userTypingString = dropLast(userTypingString)
    }
    
    func isEmpty() -> Bool {
        return (userTypingString == "")
    }
    
    func removeHeadByNumberOfWords(numberOfWords: Int) {
        if self.type == .Special {
            reset()
        } else if self.type == .EnglishOrShuangpin {    // See caller, it only could be Shuangpin
            // Get how many "_" in the pinyin of candidate
            let candidateShuangpinArray = formalizedTypingStringForQuery.string.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            let numberOfUnderscore = candidateShuangpinArray[0..<min(numberOfWords, candidateShuangpinArray.count)].reduce(0, { $0 + (contains($1, "_") ? 1 : 0) })
            // Get end
            let truncatingLength = numberOfWords * 2 - numberOfUnderscore
            if  truncatingLength < userTypingString.getReadingLength() {
                userTypingString = userTypingString.substringFromIndex(advance(userTypingString.startIndex, truncatingLength))
            } else {
                reset()
            }
        }
    }
    
    func getFormalizedTypingString(userTypingString: String, byScheme scheme: [String: String], forDisplay useForDisply: Bool) -> FormalizedTypingString {
        
        if userTypingString == "" {
            return FormalizedTypingString()
        }
        
//        func getEnglishWord(str: String) -> String? {
//            let guessedWords = textChecker.guessesForWordRange(NSMakeRange(0, str.getReadingLength()), inString: str, language: "en")
//            if guessedWords!.isEmpty {
//                return nil
//            }
//            let guess = guessedWords![0] as String
//            if guess.caseInsensitiveCompare(str) == NSComparisonResult.OrderedSame {
//                return guess
//            } else {
//                return nil
//            }
//        }
//        
//        if let word = getEnglishWord(userTypingString) {
//            return useForDisply ? FormalizedTypingString(type: .English, string: userTypingString) : FormalizedTypingString(type: .English, string: word)
//        }
        
        if userTypingString.onlyContainsLowercaseLetters() == false {    // no matter for display or not
            return FormalizedTypingString(type: .Special, string: userTypingString)
        } else if userTypingString.containsUppercaseLetters() == true {
            return FormalizedTypingString(type: .English, string: userTypingString)
        } else {
            // EnglishOrShuangpin
            var userTyping = userTypingString as NSString
            let length = userTyping.length
            var formalizedStr = ""
            var index = 0
            while index < length - 1 {
                let twoLetters = userTyping.substringWithRange(NSMakeRange(index,2))
                let newTwoLetters = scheme[twoLetters]
                if newTwoLetters != nil {
                    formalizedStr += useForDisply ? twoLetters : newTwoLetters!
                    index += 2
                } else {
                    let fst = userTyping.substringWithRange(NSMakeRange(index,1))
                    let newFst = scheme[String(fst)]!
                    formalizedStr += useForDisply ? fst: newFst
                    formalizedStr += useForDisply ? "" : "_"
                    index += 1
                }
                if index < length {
                    formalizedStr += " "
                }
            }
            if index < length {
                let fst = userTyping.substringWithRange(NSMakeRange(index,1))
                let newFst = scheme[String(fst)]!
                formalizedStr += useForDisply ? fst : newFst
            }
            
            return formalizedStr == "" ? FormalizedTypingString() : FormalizedTypingString(type: .EnglishOrShuangpin, string: formalizedStr)
        }
    }
}


class CandidatesDataModel {

    var typingString = TypingString()
    var candidates = [Candidate]()
    var cachedCandidates: [Candidate]!
    var inputHistory = InputHistory()

    var databaseQueue: FMDatabaseQueue?
    
    init() {
        
        let databasePath = NSBundle.mainBundle().pathForResource("candidates", ofType: "sqlite")
        
        databaseQueue = FMDatabaseQueue(path: databasePath)
        
        if databaseQueue == nil {
            println("Unable to open database")
            return
        }
    }
    
    deinit {
        
        databaseQueue!.close()
    }
    
    func appendTypingStringBy(newString: String, needCandidatesUpdate needUpdate: Bool = true) {
        
        if typingString.type == .Empty {
            inputHistory.updateHistory(with: .StartNewTyping)
        } else {
            inputHistory.updateHistory(with: .ContinueTyping)
        }
        
        typingString.append(newString)
        if needUpdate {
            updateDataModelRaisedByTypingChange()
        }
    }
    
    func deleteBackwardTyping(needCandidatesUpdate needUpdate: Bool = true) {
        
        typingString.deleteLast()
        if needUpdate {
            updateDataModelRaisedByTypingChange()
        }
        
        if typingString.type == .Empty {
            inputHistory.updateHistory(with: .DeleteBackwardLastTyping)
        } else {
            inputHistory.updateHistory(with: .DeleteBackwardNonLastTyping)
        }
    }
    
    func removeSelectedCandidatePinyinInTyping(candidateIndexPath: NSIndexPath, needCandidatesUpdate needUpdate: Bool = true) {
        
        let candidateText = textAt(candidateIndexPath)
        let candidate = candidateAt(candidateIndexPath)

        func substringContainingFirstSpecialCharacterOf(string: String) -> String {
            let range = string.rangeOfCharacterFromSet(NSCharacterSet.lowercaseLetterCharacterSet().invertedSet)
            return string.substringWithRange(string.startIndex...range!.startIndex)
        }
        
        if candidateIndexPath == indexPathZero {
            clearTypingAndCandidates()
            inputHistory.updateHistory(with: .SelectLastCandidate, withSelectedCandidates: candidate)
        } else {
            if typingString.type == .EnglishOrShuangpin {   // Only could be Shuangpin because not select typing
                typingString.removeHeadByNumberOfWords(candidateText!.getReadingLength())
                if typingString.type == .Empty {
                    inputHistory.updateHistory(with: .SelectLastCandidate, withSelectedCandidates: candidate)
                } else {
                    inputHistory.updateHistory(with: .SelectNonLastCandidate, withSelectedCandidates: candidate)
                }
            } else if typingString.type == .English {
                clearTypingAndCandidates()
                inputHistory.updateHistory(with: .SelectLastCandidate, withSelectedCandidates: candidate)
            } else if typingString.type == .Special {
                clearTypingAndCandidates()
                inputHistory.updateHistory(with: .SelectLastCandidate, withSelectedCandidates: candidate)
            } else {
                
            }
        }
        
        if needUpdate {
            updateDataModelRaisedByTypingChange()
        }
    }
    
    func resetTyping(needCandidatesUpdate needUpdate: Bool = true) {
        
        inputHistory.updateHistory(with: .ResetTyping)
        
        clearTypingAndCandidates()
        if needUpdate {
            updateDataModelRaisedByTypingChange()
        }
    }
    
    func clearTypingAndCandidates() {
        typingString = TypingString()
        candidates = [Candidate]()
    }
    
    func prepareUpdateDataModelRaisedByTypingChange() {
        let formalizedTypingString = typingString.formalizedTypingStringForQuery
        switch formalizedTypingString.type {
        case .Empty:
            clearTypingAndCandidates()
        case .EnglishOrShuangpin, .English, .Special:
            cachedCandidates = getCandidatesByFormalizedTypingString(typingString.formalizedTypingStringForQuery)
        }
    }
    
    func commitUpdate() {
        let formalizedTypingString = typingString.formalizedTypingStringForQuery
        switch formalizedTypingString.type {
        case .Empty:
            break
        case .EnglishOrShuangpin, .English, .Special:
            candidates = cachedCandidates
        }
    }
    
    func updateDataModelRaisedByTypingChange() {
        prepareUpdateDataModelRaisedByTypingChange()
        commitUpdate()
    }
    
    func getCandidatesByFormalizedTypingString(formalizedTypingString: FormalizedTypingString) -> [Candidate] {
        var formalizedStr: String!
        
        switch formalizedTypingString.type {
        case .Empty:
            return [Candidate]()
        case .EnglishOrShuangpin, .English, .Special:
            formalizedStr = formalizedTypingString.string
        }
        
        var index = formalizedStr.getReadingLength() - 1
        var queryArguments = [String]()
        var needTruncateCandidates = false
        var lackInternalShengmu = (contains(formalizedStr, "_"))
        
        var whereStatement = ""
        
        if formalizedTypingString.type == .English || formalizedTypingString.type == .EnglishOrShuangpin {
            queryArguments.append(String(typingString.userTypingString[formalizedStr.startIndex]))
            queryArguments.append(typingString.userTypingString.lowercaseString.stringByRemovingWhitespaceAndUnderscore())
            whereStatement += "shengmu = ? and shuangpin = ? or "
        }
        
        if formalizedTypingString.type == .EnglishOrShuangpin {
            if index % 3 == 0 { // will query with complemented yunmu
                needTruncateCandidates = true
                let strToAppend = formalizedStr + "_"
                queryArguments.append(getShengmuString(from: strToAppend))
                queryArguments.append(strToAppend)
                index -= 2
            }

            for ; index >= 0; index-=3 {
                let strToAppend = formalizedStr.substringToIndex(advance(formalizedStr.startIndex, index+1))
                queryArguments.append(getShengmuString(from: strToAppend).lowercaseString)
                queryArguments.append(strToAppend)
            }
        } else if formalizedTypingString.type == .Special {
            let strToAppend = formalizedStr
            queryArguments.append(String(strToAppend[strToAppend.startIndex]))
            queryArguments.append(strToAppend + "%")
            
        } else {
            assertionFailure("Wrong FormalizedTypingString.type")
        }
        
        var clauseCount = queryArguments.count / 2
        if formalizedTypingString.type == .English || formalizedTypingString.type == .EnglishOrShuangpin {
            clauseCount -= 1
        }
        
        whereStatement += " or ".join(Array(count: clauseCount, repeatedValue: "shengmu = ? and shuangpin like ?"))
        
        let queryStatement = "select candidate, shuangpin, candidate_type from candidates where " + whereStatement + " order by length desc, frequency desc"
        
        println(queryStatement)
        println(queryArguments)
        
        var candidates = [Candidate]()
        
        databaseQueue?.inDatabase() {
            db in
            if let rs = db.executeQuery(queryStatement, withArgumentsInArray: queryArguments) {
                while rs.next() {
                    let candidateString = rs.stringForColumn("candidate") as String
                    let queryCode = rs.stringForColumn("shuangpin") as String
                    let candidateType = rs.intForColumn("candidate_type")
                    
                    var candidate: Candidate?
                    
                    switch candidateType {
                    case 1:    // .Chinese:
                        candidate = Candidate(text: candidateString, withShuangpinString: queryCode)
                    case 2:    // .English:
                        candidate = Candidate(text: candidateString, withEnglishString: queryCode)
                    case 3:    // .Special:
                        candidate = Candidate(text: candidateString, withSpecialString: queryCode)
                    default:
                        assertionFailure("Wrong candidate type!")
                    }
                    if candidate != nil {
                        candidates.append(candidate!)
                    }
                    
                    if needTruncateCandidates && candidates.count >= 100 {
                        break
                    }
                }
            } else {
                println("select failed: \(db.lastErrorMessage())")
            }
        }
        
        let historyCandidates = inputHistory.getCandidatesByQueryArguments(queryArguments, andWhereStatement: whereStatement)
        var candidatesIndex = 0
        var historyCandidatesIndex = 0
        let candidatesLength = candidates.count
        let historyCandidatesLength = historyCandidates.count
        var retCandidates = [Candidate]()
        var addedDict = [String: Bool]()
        while candidatesIndex < candidatesLength && historyCandidatesIndex < historyCandidatesLength {
            if candidates[candidatesIndex].text.getReadingLength() <=
                historyCandidates[historyCandidatesIndex].text.getReadingLength() {
                    let historyCandidate = historyCandidates[historyCandidatesIndex]
                    if addedDict[historyCandidate.text] == nil {
                        addedDict[historyCandidate.text] = true
                        retCandidates.append(historyCandidate)
                    }
                    historyCandidatesIndex++
            } else {
                let candidate = candidates[candidatesIndex]
                if addedDict[candidate.text] == nil {
                    addedDict[candidate.text] = true
                    retCandidates.append(candidate)
                }
                candidatesIndex++
            }
        }
        if candidatesIndex == candidatesLength {
            for elem in historyCandidates[historyCandidatesIndex..<historyCandidatesLength] {
                if addedDict[elem.text] == nil {
                    addedDict[elem.text] = true
                    retCandidates.append(elem)
                }
            }
        } else if historyCandidatesIndex == historyCandidatesLength {
            for elem in candidates[candidatesIndex..<candidatesLength] {
                if addedDict[elem.text] == nil {
                    addedDict[elem.text] = true
                    retCandidates.append(elem)
                }
            }
        } else {
            assertionFailure("Something wrong")
        }

        println("\(candidates.count) candidates are returned")
        return retCandidates
    }
    
    func hasTyping() -> Bool {
        if typingString.isEmpty() {
            return false
        } else {
            return true
        }
    }
    
    func numberOfTypingAndCandidates() -> Int {
        return 1 + candidates.count
    }
    
    func getUserTypingString() -> String {
        return typingString.userTypingString
    }
    
    func textAt(indexPath: NSIndexPath) -> String? {
        if indexPath.row >= numberOfTypingAndCandidates() {
            return nil
        }
        if indexPath == indexPathZero {
            return typingString.displayedString
        } else {
            return candidateAt(indexPath).text
        }
    }
    
    func candidateAt(indexPath: NSIndexPath) -> Candidate {
        if indexPath == indexPathZero {
            let userTyping = typingString.userTypingString
            if userTyping.containsNonLetters() == true {
                return Candidate(text: userTyping, withSpecialString: userTyping)
            } else {
                return Candidate(text: userTyping, withEnglishString: userTyping.lowercaseString)
            }
        } else {
            return candidates[indexPath.row - 1]
        }
    }
    
    func allText() -> [String] {
        return [textAt(indexPathZero)!] + candidates.map({x in return x.text})
    }
    

}

