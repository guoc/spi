import UIKit

extension FMDatabaseQueue {
    func getCandidates(byQueryStatement queryStatement: String, byQueryArguments queryArguments: [String], needTruncateCandidates: Bool) -> [Candidate] {
        
        var candidates = [Candidate]()
        self.inDatabase() {
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
                    case 4:    // .Custom:
                        candidate = Candidate(text: candidateString, withCustomString: queryCode)
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
        return candidates
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
        
        func mergeCandidatesArrays(candidatesA: [Candidate], candidatesB: [Candidate]) -> [Candidate] {
            
            var candidatesAIndex = 0
            var candidatesBIndex = 0
            let candidatesALength = candidatesA.count
            let candidatesBLength = candidatesB.count
            var retCandidates = [Candidate]()
            var addedDict = [String: Bool]()
            
            while candidatesAIndex < candidatesALength && candidatesBIndex < candidatesBLength {
                if candidatesA[candidatesAIndex].queryCode.getReadingLength() <=
                    candidatesB[candidatesBIndex].queryCode.getReadingLength() {
                        let historyCandidate = candidatesB[candidatesBIndex]
                        if addedDict[historyCandidate.text] == nil {
                            addedDict[historyCandidate.text] = true
                            retCandidates.append(historyCandidate)
                        }
                        candidatesBIndex++
                } else {
                    let candidate = candidatesA[candidatesAIndex]
                    if addedDict[candidate.text] == nil {
                        addedDict[candidate.text] = true
                        retCandidates.append(candidate)
                    }
                    candidatesAIndex++
                }
            }
            if candidatesAIndex == candidatesALength {
                for elem in candidatesB[candidatesBIndex..<candidatesBLength] {
                    if addedDict[elem.text] == nil {
                        addedDict[elem.text] = true
                        retCandidates.append(elem)
                    }
                }
            } else if candidatesBIndex == candidatesBLength {
                for elem in candidatesA[candidatesAIndex..<candidatesALength] {
                    if addedDict[elem.text] == nil {
                        addedDict[elem.text] = true
                        retCandidates.append(elem)
                    }
                }
            } else {
                assertionFailure("Something wrong")
            }
            
            return retCandidates
        }
        
        func getAccurateCandidatesFirstCandidatesArray(candidates: [Candidate], withQueryCode queryCode: String) -> [Candidate] {
            let accurateCandidates = candidates.filter { $0.queryCode == queryCode }
            let inaccurateCandidates = candidates.filter { $0.queryCode != queryCode }
            return accurateCandidates + inaccurateCandidates
        }
        
        if formalizedTypingString.type == .Empty {
            return [Candidate]()
        }
        
        // Below formalizedTypingString.type == .EnglishOrShuangpin || .English || .Special
        
        var formalizedStr = formalizedTypingString.string
        let originalStr = formalizedTypingString.originalString
        var index = formalizedStr.getReadingLength() - 1
        var needTruncateCandidates = false
        var lackInternalShengmu = (contains(formalizedStr, "_"))
        var queryArguments = [String]()
        var clauseCount = 0
        var whereStatement = ""
        
        switch formalizedTypingString.type {
            
        case .EnglishOrShuangpin:
            
            // Prepare ACCURATE query if typing may be English
            queryArguments.append(String(typingString.remainingUserTypingString[typingString.remainingUserTypingString.startIndex]))
            queryArguments.append(typingString.remainingUserTypingString.lowercaseString)
            whereStatement += "shengmu = ? and shuangpin = ? or "
            
            // Prepare query if typing may be shuangpin
            
            // Last shuangpin may be incomplete, handle this according to the position of current index.
            switch index % 3 {
            case 0:    // xx xx x
                // will query with complemented yunmu
                needTruncateCandidates = true
                let strToAppend = formalizedStr + "_"
                queryArguments.append(getShengmuString(from: strToAppend))
                queryArguments.append(strToAppend)
                clauseCount++
                index -= 2
            case 1:    // xx xx xx
                break    // Empty statement
            case 2:    // xx xx( )    last character is whitespace
                assertionFailure("Bad formalizedTypingString")
            default:    // Impossible
                break    // Empty statement
            }

            // Handle left typing
            for ; index >= 0; index-=3 {
                let strToAppend = formalizedStr.substringToIndex(advance(formalizedStr.startIndex, index+1))
                queryArguments.append(getShengmuString(from: strToAppend).lowercaseString)
                queryArguments.append(strToAppend)
                clauseCount++
            }
            
        case .English:
            let strToAppend = formalizedStr.lowercaseString
            queryArguments.append(String(strToAppend[strToAppend.startIndex]))
            queryArguments.append(strToAppend + "%")
            clauseCount++
        case .Special:
            let strToAppend = formalizedStr
            queryArguments.append(String(strToAppend[strToAppend.startIndex]))
            queryArguments.append(strToAppend + "%")
            clauseCount++
        case .Empty:
            assertionFailure(".Empty has already returned!")
        }
        
        whereStatement += " or ".join(Array(count: clauseCount, repeatedValue: "shengmu = ? and shuangpin like ?"))
        
        let queryStatement = "select candidate, shuangpin, candidate_type from candidates where " + whereStatement + " order by length desc, frequency desc"
        
        println(queryStatement)
        println(queryArguments)
        
        var candidates = databaseQueue!.getCandidates(byQueryStatement: queryStatement, byQueryArguments: queryArguments, needTruncateCandidates: needTruncateCandidates)
        let historyCandidates = inputHistory.getCandidatesByQueryArguments(queryArguments, andWhereStatement: whereStatement)
        
        let mergedCandidates = mergeCandidatesArrays(candidates, historyCandidates)
        println("\(mergedCandidates.count) candidates are returned")
        
        let accurateCandidatesFirstCandidates = getAccurateCandidatesFirstCandidatesArray(mergedCandidates, withQueryCode: formalizedTypingString.originalString)
        
        return accurateCandidatesFirstCandidates
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

