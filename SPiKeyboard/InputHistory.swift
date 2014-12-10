
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
