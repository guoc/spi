
import Foundation

enum InputAction {
    case StartNewTyping, ContinueTyping, SelectNonLastCandidate, SelectLastCandidate, DeleteBackwardNonLastTyping, DeleteBackwardLastTyping, ResetTyping
}

enum TypingState {
    case Empty, NonEmpty
}

class InputHistory {
    
    var currentTypingState = TypingState.Empty
    var candidatesRecord = [Candidate]()
    var history = [String: Int]()
    
    var databaseQueue: FMDatabaseQueue?
    
    init() {
        let documentsFolder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let databasePath = documentsFolder.stringByAppendingPathComponent("history.sqlite")
        println(databasePath)
        
        databaseQueue = FMDatabaseQueue(path: databasePath)
        
        if databaseQueue == nil {
            println("Unable to open database")
            return
        }
        
        databaseQueue?.inDatabase() {
            db in
            if !db.executeUpdate("create table if not exists history(candidate text, shuangpin text, shengmu text, length integer, frequency integer, candidate_type integer, primary key (candidate, shuangpin))", withArgumentsInArray: nil) {
                println("create table failed: \(db.lastErrorMessage())")
            }
        }
    }
    
    deinit {
        databaseQueue!.close()
    }
    
    func getFrequencyOf(candidate: Candidate) -> Int {

        var frequency: Int? = nil
        var whereStatement = "candidate = ? and shuangpin = ?"
        let queryStatement = "select frequency from history where " + whereStatement + " order by length desc, frequency desc"

        databaseQueue?.inDatabase() {
            db in
            if let rs = db.executeQuery(queryStatement, withArgumentsInArray: [candidate.text, candidate.queryCode]) {
                while rs.next() {
                    frequency = Int(rs.intForColumn("frequency"))
                    break
                }
            } else {
                println("select failed: \(db.lastErrorMessage())")
            }
        }
        return frequency ?? 0
    }
    
    func updateDatabase(with candidate: Candidate) {
        
        let frequency = getFrequencyOf(candidate)
        
        databaseQueue?.inDatabase() {
            db in
            if frequency == 0 {
                if !db.executeUpdate("insert into history (candidate, shuangpin, shengmu, length, frequency, candidate_type) values (?, ?, ?, ?, ?, ?)", withArgumentsInArray: [candidate.text, candidate.shuangpinAttributeString, candidate.shengmuAttributeString, candidate.lengthAttributeString as NSNumber, 1, candidate.typeAttributeString]) {
                    println("insert 1 table failed: \(db.lastErrorMessage()) \(candidate.text) \(candidate.shuangpinAttributeString)")
                }
            } else {
                if !db.executeUpdate("update history set frequency = ? where shuangpin = ? and candidate = ?", withArgumentsInArray: [frequency + 1, candidate.shuangpinAttributeString, candidate.text]) {
                    println("update 1 table failed: \(db.lastErrorMessage()) \(candidate.text) \(candidate.shuangpinAttributeString)")
                }
            }
        }
    }
    
    func updateHistory(with inputAction: InputAction, withSelectedCandidates selectedCandidate: Candidate? = nil) {
        print(inputAction)
        switch (inputAction) {
        case .StartNewTyping:
            assert(currentTypingState == .Empty, "Action \(inputAction) should start with state .Empty")
            currentTypingState = .NonEmpty
        case .ContinueTyping:
            assert(currentTypingState == .NonEmpty, "Action \(inputAction) should start with state .NonEmpty")
            currentTypingState = .NonEmpty
        case .SelectNonLastCandidate:
            assert(currentTypingState == .NonEmpty, "Action \(inputAction) should start with state .NonEmpty")
            currentTypingState = .NonEmpty
            candidatesRecord.append(selectedCandidate!)
            updateDatabase(with: selectedCandidate!)
        case .SelectLastCandidate:
            assert(currentTypingState == .NonEmpty, "Action \(inputAction) should start with state .NonEmpty")
            currentTypingState = .Empty
            candidatesRecord.append(selectedCandidate!)
            if candidatesRecord.count > 1 {
                updateDatabase(with: selectedCandidate!)
            }
            func sumCandidatesRecord() -> Candidate? {
                var sumText = ""
                var queryCodeArray = [String]()
                var type: CandidateType = candidatesRecord[0].type
                for candidate in candidatesRecord {
                    if candidate.type != candidatesRecord[0].type {
                        return nil
                    }
                    sumText += candidate.text
                    queryCodeArray.append(candidate.queryCode)
                }
                let sumQueryCode = " ".join(queryCodeArray)
                return Candidate(text: sumText, type: type, queryString: sumQueryCode)
            }
            if let sumCandidate = sumCandidatesRecord() {
                updateDatabase(with: sumCandidate)
            }
            candidatesRecord = [Candidate]()
            println(history)
        case .DeleteBackwardNonLastTyping:
            assert(currentTypingState == .NonEmpty, "Action \(inputAction) should start with state .NonEmpty")
            currentTypingState = .NonEmpty
            candidatesRecord = [Candidate]()
        case .DeleteBackwardLastTyping:
            assert(currentTypingState == .NonEmpty, "Action \(inputAction) should start with state .NonEmpty")
            currentTypingState = .Empty
            candidatesRecord = [Candidate]()
        case .ResetTyping:
            currentTypingState = .Empty
            candidatesRecord = [Candidate]()
        }
    }
    
    func getCandidatesByQueryArguments(queryArguments: [String], andWhereStatement whereStatement: String) -> [Candidate] {
        var candidates = [Candidate]()
        let queryStatement = "select candidate, shuangpin, candidate_type from history where " + whereStatement + " order by length desc, frequency desc"
        println(queryStatement)
        println(queryArguments)
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
                    if candidates.count >= 100 {
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
