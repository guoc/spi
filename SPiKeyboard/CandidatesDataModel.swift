import UIKit

extension FMDatabaseQueue {
    func getCandidates(byQueryStatement queryStatement: String, byQueryArguments queryArguments: [String], withQueryCode candidateQueryCode: String, needTruncateCandidates: Bool) -> [Candidate] {
        
        var candidates = [Candidate]()
        self.inDatabase() {
            db in
            if let rs = db?.executeQuery(queryStatement, withArgumentsIn: queryArguments) {
                while rs.next() {
                    let candidateString = rs.string(forColumn: "candidate") as String
                    let queryCode = rs.string(forColumn: "shuangpin") as String
                    let candidateType = rs.int(forColumn: "candidate_type")
                    
                    var candidate: Candidate?
                    
                    switch candidateType {
                    case 1:    // .Chinese:
                        candidate = Candidate(text: candidateString, withShuangpinString: queryCode)
                    case 2:    // .English:
                        candidate = Candidate(text: candidateString, withEnglishString: queryCode)
                    case 3:    // .Special:
                        candidate = Candidate(text: candidateString, withSpecialString: queryCode)
                    case 4:    // .Custom:
                        if queryCode == candidateQueryCode {
                            candidate = Candidate(text: candidateString, withCustomString: queryCode)
                        } else {
                            
                        }
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
                print("select failed: \(db?.lastErrorMessage())")
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
        
        let databasePath = Bundle.main.path(forResource: "candidates", ofType: "sqlite")
        
        databaseQueue = FMDatabaseQueue(path: databasePath)
        
        if databaseQueue == nil {
            print("Unable to open database")
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
    
    func appendTypingStringBy(_ newString: String, needCandidatesUpdate needUpdate: Bool = true) {
        
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
    
    func updateTypingWithSelectedCandidateAt(_ candidateIndexPath: IndexPath, needCandidatesUpdate needUpdate: Bool = true) {
        
        let candidateText = textAt(candidateIndexPath)
        let candidate = candidateAt(candidateIndexPath)

        func substringContainingFirstSpecialCharacterOf(_ string: String) -> String {
            let range = string.rangeOfCharacter(from: CharacterSet.lowercaseLetters.inverted)
            return string.substring(with: string.startIndex..<string.index(after: range!.lowerBound))
        }
        
        if candidateIndexPath == indexPathZero {
            inputHistory.updateHistoryWith(candidate)
            reset()
        } else {
            typingString.updateBySelectedCandidate(candidate)
            if typingString.typeOfRemainingFormalizedTyping == .empty {
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
        case .empty:
            if typingString.readyToInsert() == true {
                
            } else {
                reset()
            }
        case .englishOrShuangpin, .english, .special:
            cachedCandidates = getCandidatesByFormalizedTypingString(typingString.remainingFormalizedTypingStringForQuery)
        }
    }
    
    func commitUpdate() {
        let formalizedTypingString = typingString.remainingFormalizedTypingStringForQuery
        switch formalizedTypingString.type {
        case .empty:
            break
        case .englishOrShuangpin, .english, .special:
            candidates = cachedCandidates
        }
    }
    
    func updateDataModelRaisedByTypingChange() {
        prepareUpdateDataModelRaisedByTypingChange()
        commitUpdate()
    }
    
    func getCandidatesByFormalizedTypingString(_ formalizedTypingString: FormalizedTypingString) -> [Candidate] {
        
        func mergeCandidatesArrays(_ candidatesA: [Candidate], candidatesB: [Candidate]) -> [Candidate] {
            
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
                        candidatesBIndex += 1
                } else {
                    let candidate = candidatesA[candidatesAIndex]
                    if addedDict[candidate.text] == nil {
                        addedDict[candidate.text] = true
                        retCandidates.append(candidate)
                    }
                    candidatesAIndex += 1
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
        
        func getAccurateCandidatesFirstCandidatesArray(_ candidates: [Candidate], withQueryCode queryCode: String) -> [Candidate] {
            let accurateCandidates = candidates.filter { $0.queryCode == queryCode }
            let inaccurateCandidates = candidates.filter { $0.queryCode != queryCode }
            return accurateCandidates + inaccurateCandidates
        }
        
        if formalizedTypingString.type == .empty {
            return [Candidate]()
        }
        
        // Below formalizedTypingString.type == .EnglishOrShuangpin || .English || .Special
        
        let formalizedStr = formalizedTypingString.string
        _ = formalizedTypingString.originalString    // originalStr
        var index = formalizedStr.getReadingLength() - 1
        var needTruncateCandidates = false
        _ = (formalizedStr.characters.contains("_"))    // lackInternalShengmu
        var queryArguments = [String]()
        var clauseCount = 0
        var whereStatement = ""
        
        switch formalizedTypingString.type {
            
        case .englishOrShuangpin:
            
            // Prepare ACCURATE query if typing may be English
            if typingString.remainingUserTypingString.getReadingLength() > 2 {
                // Accurate query should only be used when remainingUserTypingString > 2, otherwise
                // it may confuse shuangpin query by non-ziranma scheme.
                // e.g.
                // In xiaohe scheme "dc" -> "dk" -> "dao", if accurate query is used,
                // candidates of "diao" will be returned, because in ziranma scheme "dc" -> "diao"
                queryArguments.append(String(typingString.remainingUserTypingString[typingString.remainingUserTypingString.startIndex]))
                queryArguments.append(typingString.remainingUserTypingString.lowercased())
                whereStatement += "shengmu = ? and shuangpin = ? or "
            }
            
            // Prepare query if typing may be shuangpin
            
            // Last shuangpin may be incomplete, handle this according to the position of current index.
            switch index % 3 {
            case 0:    // xx xx x
                // will query with complemented yunmu
                needTruncateCandidates = true
                let strToAppend = formalizedStr + "_"
                queryArguments.append(getShengmuString(from: strToAppend))
                queryArguments.append(strToAppend)
                clauseCount += 1
                index -= 2
            case 1:    // xx xx xx
                break    // Empty statement
            case 2:    // xx xx( )    last character is whitespace
                assertionFailure("Bad formalizedTypingString")
            default:    // Impossible
                break    // Empty statement
            }

            // Handle left typing
            for i in stride(from: index, through: 0, by: -3) {
                let strToAppend = formalizedStr.substring(to: formalizedStr.characters.index(formalizedStr.startIndex, offsetBy: i+1))
                queryArguments.append(getShengmuString(from: strToAppend).lowercased())
                queryArguments.append(strToAppend)
                clauseCount += 1
            }
            
        case .english:
            let strToAppend = formalizedStr.lowercased()
            queryArguments.append(String(strToAppend[strToAppend.startIndex]))
            queryArguments.append(strToAppend + "%")
            clauseCount += 1
        case .special:
            let strToAppend = formalizedStr
            queryArguments.append(String(strToAppend[strToAppend.startIndex]))
            queryArguments.append(strToAppend + "%")
            clauseCount += 1
        case .empty:
            assertionFailure(".Empty has already returned!")
        }
        
        whereStatement += Array(repeating: "shengmu = ? and shuangpin like ?", count: clauseCount).joined(separator: " or ")
        
        let queryStatement = "select candidate, shuangpin, candidate_type from candidates where " + whereStatement + " order by length desc, frequency desc"
        
        print(queryStatement)
        print(queryArguments)
        
        let candidates = databaseQueue!.getCandidates(byQueryStatement: queryStatement, byQueryArguments: queryArguments, withQueryCode: formalizedTypingString.originalString, needTruncateCandidates: needTruncateCandidates)
        let historyCandidates = inputHistory.getCandidatesByQueryArguments(queryArguments, andWhereStatement: whereStatement, withQueryCode: formalizedTypingString.originalString)
        
        let mergedCandidates = mergeCandidatesArrays(candidates, candidatesB: historyCandidates)
        print("\(mergedCandidates.count) candidates are returned")
        
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
    
    func textAt(_ indexPath: IndexPath) -> String? {
        if indexPath.row >= numberOfTypingAndCandidates() {
            return nil
        }
        if indexPath == indexPathZero {
            return typingString.displayedString
        } else {
            return candidateAt(indexPath).text
        }
    }
    
    func candidateAt(_ indexPath: IndexPath) -> Candidate {
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

