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



class CandidatesDataModel {

    var typingString = TypingString()
    var candidates = [Candidate]()
    var cachedCandidates: [Candidate]!    // For two-stage update data to avoid update UI in background thread
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
    
    func reset() {
        typingString = TypingString()
        candidates = [Candidate]()
        cachedCandidates = nil
        inputHistory = InputHistory()
    }
    
    func appendTypingStringBy(newString: String, needCandidatesUpdate needUpdate: Bool = true) {
        
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
    }
    
    func updateTypingWithSelectedCandidateAt(candidateIndexPath: NSIndexPath, needCandidatesUpdate needUpdate: Bool = true) {
        
        let candidateText = textAt(candidateIndexPath)
        let candidate = candidateAt(candidateIndexPath)

        func substringContainingFirstSpecialCharacterOf(string: String) -> String {
            let range = string.rangeOfCharacterFromSet(NSCharacterSet.lowercaseLetterCharacterSet().invertedSet)
            return string.substringWithRange(string.startIndex...range!.startIndex)
        }
        
        if candidateIndexPath == indexPathZero {
            inputHistory.updateHistoryWith(candidate)
            reset()
        } else {
            typingString.updateBySelectedCandidate(candidate)
            if typingString.typeOfRemainingFormalizedTyping == .Empty {
                inputHistory.updateHistoryWith(typingString.getCandidate())
            } else {

            }
        }
        
        if needUpdate {
            updateDataModelRaisedByTypingChange()
        }
    }
    
    func resetTyping(needCandidatesUpdate needUpdate: Bool = true) {
        
        reset()
        if needUpdate {
            updateDataModelRaisedByTypingChange()
        }
    }
    
    func prepareUpdateDataModelRaisedByTypingChange() {
        let formalizedTypingString = typingString.remainingFormalizedTypingStringForQuery
        switch formalizedTypingString.type {
        case .Empty:
            if typingString.readyToInsert() == true {
                
            } else {
                reset()
            }
        case .EnglishOrShuangpin, .English, .Special:
            cachedCandidates = getCandidatesByFormalizedTypingString(typingString.remainingFormalizedTypingStringForQuery)
        }
    }
    
    func commitUpdate() {
        let formalizedTypingString = typingString.remainingFormalizedTypingStringForQuery
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
            return typingString.getCandidate()
        } else {
            return candidates[indexPath.row - 1]
        }
    }
    
    func allText() -> [String] {
        return [textAt(indexPathZero)!] + candidates.map({x in return x.text})
    }
    
    func getTypingCompleteCachedCandidate() -> String? {
        if typingString.readyToInsert() {
            return typingString.joinedCandidate
        } else {
            return nil
        }
    }
    

}

