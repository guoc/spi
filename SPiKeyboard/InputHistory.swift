
import Foundation

class InputHistory {
    
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
            
            if !db.executeUpdate("CREATE INDEX IF NOT EXISTS idx_shengmu on history(shengmu)", withArgumentsInArray: nil) {
                println("create index failed: \(db.lastErrorMessage())")
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
    
    func updateDatabase(#candidatesString: String) {
        let candidatesArray = candidatesString.componentsSeparatedByString("\n")
        for candidateStr in candidatesArray {
            if candidateStr != "" {
                let arr = candidateStr.componentsSeparatedByString("\t")
                updateDatabase(candidateText: arr[0], customCandidateQueryString: arr[1])
            }
        }
    }
    
    func updateDatabase(#candidateText: String, customCandidateQueryString: String) {
        updateDatabase(with: Candidate(text: candidateText, withCustomString: customCandidateQueryString))
    }
    
    func updateDatabase(with candidate: Candidate) {
        
        func canInsertIntoInputHistory(candidate: Candidate) -> Bool {
            
            func candidateIsTooSimple(candidate: Candidate) -> Bool {
                if candidate.queryCode.getReadingLength() == 2 && candidate.text == candidate.queryCode || candidate.queryCode.getReadingLength() == 1 {
                    return true
                } else {
                    return false
                }
            }
            
            if candidateIsTooSimple(candidate) {
                return false
            } else {
                return true
            }
        }
        
        if canInsertIntoInputHistory(candidate) == false {
            return
        }
        
        let frequency = getFrequencyOf(candidate)
        
        databaseQueue?.inDatabase() {
            db in
            if frequency == 0 {
                if !db.executeUpdate("insert into history (candidate, shuangpin, shengmu, length, frequency, candidate_type) values (?, ?, ?, ?, ?, ?)", withArgumentsInArray: [candidate.text, candidate.shuangpinAttributeString, candidate.shengmuAttributeString, candidate.lengthAttribute as NSNumber, 1, candidate.typeAttributeString]) {
                    println("insert 1 table failed: \(db.lastErrorMessage()) \(candidate.text) \(candidate.shuangpinAttributeString)")
                }
            } else {
                if !db.executeUpdate("update history set frequency = ? where shuangpin = ? and candidate = ?", withArgumentsInArray: [frequency + 1, candidate.shuangpinAttributeString, candidate.text]) {
                    println("update 1 table failed: \(db.lastErrorMessage()) \(candidate.text) \(candidate.shuangpinAttributeString)")
                }
            }
        }
    }
    
    func updateHistoryWith(candidate: Candidate) {
        if candidate.type == .OnlyText {
            return
        }
        updateDatabase(with: candidate)
    }
    
    func getCandidatesByQueryArguments(queryArguments: [String], andWhereStatement whereStatement: String, withQueryCode queryCode: String) -> [Candidate] {
        let queryStatement = "select candidate, shuangpin, candidate_type from history where " + whereStatement + " order by length desc, frequency desc"
        println(queryStatement)
        println(queryArguments)
        let candidates = databaseQueue!.getCandidates(byQueryStatement: queryStatement, byQueryArguments: queryArguments, withQueryCode: queryCode, needTruncateCandidates: false)
        
        return candidates
    }
    
}
