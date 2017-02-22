
import Foundation

class InputHistory {
    
    var candidatesRecord = [Candidate]()
    var history = [String: Int]()
    
    var databaseQueue: FMDatabaseQueue?
    
    var recentCandidate: (text: String, querycode: String)? {
        set {
            UserDefaults.standard.set(newValue?.text, forKey: "InputHistory.recentCandidate.text")
            UserDefaults.standard.set(newValue?.querycode, forKey: "InputHistory.recentCandidate.querycode")
        }
        get {
            if let text = UserDefaults.standard.object(forKey: "InputHistory.recentCandidate.text") as? String, let querycode = UserDefaults.standard.object(forKey: "InputHistory.recentCandidate.querycode") as? String {
                return (text: text, querycode: querycode)
            } else {
                return nil
            }
        }
    }
    
    init() {
        let documentsFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let databasePath = URL(string: documentsFolder)!.appendingPathComponent("history.sqlite")
        print(databasePath)
        
        databaseQueue = FMDatabaseQueue(path: databasePath.absoluteString)
        
        if databaseQueue == nil {
            print("Unable to open database")
            return
        }
        
        databaseQueue?.inDatabase() {
            db in
            if !(db?.executeUpdate("create table if not exists history(candidate text, shuangpin text, shengmu text, length integer, frequency integer, candidate_type integer, primary key (candidate, shuangpin))", withArgumentsIn: nil))! {
                print("create table failed: \(db?.lastErrorMessage())")
            }
            
            if !(db?.executeUpdate("CREATE INDEX IF NOT EXISTS idx_shengmu on history(shengmu)", withArgumentsIn: nil))! {
                print("create index failed: \(db?.lastErrorMessage())")
            }
        }
    }
    
    deinit {
        databaseQueue!.close()
    }
    
    func getFrequencyOf(_ candidate: Candidate) -> Int {
        return getFrequencyOf(candidateText: candidate.text, queryCode: candidate.queryCode)
    }
    
    func getFrequencyOf(candidateText: String, queryCode: String) -> Int {
        var frequency: Int? = nil
        let whereStatement = "candidate = ? and shuangpin = ?"
        let queryStatement = "select frequency from history where " + whereStatement + " order by length desc, frequency desc"
        
        databaseQueue?.inDatabase() {
            db in
            if let rs = db?.executeQuery(queryStatement, withArgumentsIn: [candidateText, queryCode]) {
                while rs.next() {
                    frequency = Int(rs.int(forColumn: "frequency"))
                    break
                }
            } else {
                print("select failed: \(db?.lastErrorMessage())")
            }
        }
        return frequency ?? 0
    }
    
    func updateDatabase(candidatesString: String) {
        let candidatesArray = candidatesString.components(separatedBy: "\n")
        for candidateStr in candidatesArray {
            if candidateStr != "" {
                let arr = candidateStr.components(separatedBy: "\t")
                updateDatabase(candidateText: arr[0], customCandidateQueryString: arr[1])
            }
        }
    }
    
    func updateDatabase(candidateText: String, queryString: String, candidateType: String) -> Bool {
        switch candidateType {
        case "1":
            updateDatabase(candidateText: candidateText, shuangpinString: queryString)
            return true
        case "2":
            updateDatabase(candidateText: candidateText, englishString: queryString)
            return true
        case "3":
            updateDatabase(candidateText: candidateText, specialString: queryString)
            return true
        case "4":
            updateDatabase(candidateText: candidateText, customCandidateQueryString: queryString)
            return true
        default:
            return false
        }
    }
    
    func updateDatabase(candidateText: String, customCandidateQueryString: String) {
        updateDatabase(with: Candidate(text: candidateText, withCustomString: customCandidateQueryString))
    }
    
    func updateDatabase(candidateText: String, shuangpinString: String) {
        updateDatabase(with: Candidate(text: candidateText, withShuangpinString: shuangpinString))
    }

    func updateDatabase(candidateText: String, englishString: String) {
        updateDatabase(with: Candidate(text: candidateText, withEnglishString: englishString))
    }
    
    func updateDatabase(candidateText: String, specialString: String) {
        updateDatabase(with: Candidate(text: candidateText, withSpecialString: specialString))
    }
    
    func updateDatabase(with candidate: Candidate) {
        
        func canInsertIntoInputHistory(_ candidate: Candidate) -> Bool {
            
            func candidateIsTooSimple(_ candidate: Candidate) -> Bool {
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
        
        self.recentCandidate = (text: candidate.text, querycode: candidate.shuangpinAttributeString)

        if canInsertIntoInputHistory(candidate) == false {
            return
        }
        
        updateDatabase(candidateText: candidate.text, shuangpin: candidate.shuangpinAttributeString, shengmu: candidate.shengmuAttributeString, length: candidate.lengthAttribute as NSNumber, frequency: 1 as NSNumber, candidateType: candidate.typeAttributeString)
    }
    
    func updateDatabase(candidateText: String, shuangpin: String, shengmu: String, length: NSNumber, frequency: NSNumber, candidateType: String) {
        let previousFrequency = getFrequencyOf(candidateText: candidateText, queryCode: shuangpin)
        
        databaseQueue?.inDatabase() {
            db in
            if previousFrequency == 0 {
                if !(db?.executeUpdate("insert into history (candidate, shuangpin, shengmu, length, frequency, candidate_type) values (?, ?, ?, ?, ?, ?)", withArgumentsIn: [candidateText, shuangpin, shengmu, length, frequency, candidateType]))! {
                    print("insert 1 table failed: \(db?.lastErrorMessage()) \(candidateText) \(shuangpin)")
                }
            } else {
                if !(db?.executeUpdate("update history set frequency = ? where shuangpin = ? and candidate = ?", withArgumentsIn: [NSNumber(value: previousFrequency + frequency.intValue as Int), shuangpin, candidateText]))! {
                    print("update 1 table failed: \(db?.lastErrorMessage()) \(candidateText) \(shuangpin)")
                }
            }
        }
    }
    
    func updateHistoryWith(_ candidate: Candidate) {
        if candidate.type == .onlyText {
            return
        }
        updateDatabase(with: candidate)
    }
    
    func deleteRecentCandidate() {
        databaseQueue?.inDatabase() {
            db in
            if let candidate = self.recentCandidate {
                if !(db?.executeUpdate("delete from history where candidate == ? and shuangpin == ?", withArgumentsIn: [candidate.text, candidate.querycode]))! {
                    print("delete 1 table failed: \(db?.lastErrorMessage()) \(candidate.text) \(candidate.querycode)")
                }
                self.recentCandidate = nil
            }
        }
    }
    
    func cleanAllCandidates() {    // Drop table in database.
        databaseQueue?.inDatabase() {
            db in
            if !(db?.executeUpdate("drop table history", withArgumentsIn: []))! {
                print("drop table history failed: \(db?.lastErrorMessage())")
            }
        }
    }
    
    func getCandidatesByQueryArguments(_ queryArguments: [String], andWhereStatement whereStatement: String, withQueryCode queryCode: String) -> [Candidate] {
        let queryStatement = "select candidate, shuangpin, candidate_type from history where " + whereStatement + " order by length desc, frequency desc"
        print(queryStatement)
        print(queryArguments)
        let candidates = databaseQueue!.getCandidates(byQueryStatement: queryStatement, byQueryArguments: queryArguments, withQueryCode: queryCode, needTruncateCandidates: false)
        
        return candidates
    }
    
}
