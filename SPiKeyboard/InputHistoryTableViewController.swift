
import UIKit

typealias Row = [AnyHashable: Any]

class InputHistoryTableViewController: UITableViewController {

    var rows: [Row] = [] {
        didSet {
            rowIndex = getRowIndex(rows)
        }
    }
    var rowIndex: [Character: [Row]]! {
        didSet {
            indexNames = Array(rowIndex.keys).sorted { String($0).localizedCaseInsensitiveCompare(String($1)) == ComparisonResult.orderedAscending }
        }
    }
    var indexNames: [Character]!
    
    /*
    override init() {
        super.init(style: UITableViewStyle.Plain)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Need this to prevent runtime error:
    // fatal error: use of unimplemented initializer 'init(nibName:bundle:)'
    // for class 'TestViewController'
    // I made this private since users should use the no-argument constructor.
    private override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
*/
    
    let enableAdvanceCell = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if enableAdvanceCell {
            tableView.register(UINib(nibName: "AdvanceInputHistoryRowCell", bundle: nil), forCellReuseIdentifier: "advanceInputHistoryRowCell")
        } else {
            tableView.register(InputHistoryRowCell.self, forCellReuseIdentifier: "inputHistoryRowCell")
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        rows = getAllRows()
        
        self.rows = self.rows.filter {
            self.candidateTextIsInCandidatesDatabase($0["candidate"] as! String) == false
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return rowIndex.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (indexNames.count != 0) ? rowIndex[indexNames[section]]!.count : 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (indexNames.count != 0) ? String(indexNames[section]) : nil
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return indexNames.map { return String($0) }
    }
    
    func rowForIndexPath(_ indexPath: IndexPath) -> Row {
        let indexName = indexNames[indexPath.section]
        let rows = rowIndex[indexName]!
        return rows[indexPath.row]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if enableAdvanceCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "advanceInputHistoryRowCell", for: indexPath) as! AdvanceInputHistoryRowCell
            let row = rowForIndexPath(indexPath)
            cell.candidateLabel.text = (row["candidate"] as! String)
            cell.shuangpinLabel.text = (row["shuangpin"] as! String)
            cell.shengmuLabel.text = (row["shengmu"] as! String)
            cell.lengthLabel.text = String((row["length"] as! NSNumber).intValue)
            cell.frequencyLabel.text = String((row["frequency"] as! NSNumber).intValue)
            switch (row["candidate_type"] as! NSNumber).intValue {
            case 1:
                cell.typeLabel.text = "中"
            case 2:
                cell.typeLabel.text = "英"
            case 3:
                cell.typeLabel.text = "符"
            default:
                assertionFailure("Wrong candidate type in history.sqlite")
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "inputHistoryRowCell", for: indexPath) as! InputHistoryRowCell
            let row = rowForIndexPath(indexPath)
            cell.textLabel?.text = row["candidate"] as? String
            cell.detailTextLabel?.text = row["shuangpin"] as? String
            return cell
        }
    }
    
    lazy var _inputHistoryDatabaseQueue: FMDatabaseQueue! = {
        let documentsFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] 
        let databasePath = URL(string: documentsFolder)!.appendingPathComponent("history.sqlite")
        
        let databaseQueue = FMDatabaseQueue(path: databasePath.absoluteString)
        
        if databaseQueue == nil {
            print("Unable to open database")
        }
        
        return databaseQueue
    }()
    
    func getAllRows() -> [Row] {
        var rows: [Row] = []
        
        _inputHistoryDatabaseQueue.inDatabase() {
            db in
            if let rs = db?.executeQuery("select candidate, shuangpin, shengmu, length, frequency, candidate_type from history order by shengmu", withArgumentsIn: nil) {
                while rs.next() {
                    rows.append(rs.resultDictionary())
                }
            } else {
                print("select failed: \(db?.lastErrorMessage())")
            }
        }
        
        rows.sort {
            ($0["frequency"] as! NSNumber).intValue > ($1["frequency"] as! NSNumber).intValue
        }
        
        return rows
    }
    
    func getRowIndex(_ rows: [Row]) -> [Character: [Row]] {
        
        func distinct<T: Equatable>(_ source: [T]) -> [T] {
            var unique = [T]()
            for item in source {
                if !unique.contains(item) {
                    unique.append(item)
                }
            }
            return unique
        }
        
        func firstLetter(_ row: Row) -> Character {
            let str = row["shengmu"]! as! String
            return Character(str.substring(to: str.characters.index(str.startIndex, offsetBy: 1)).uppercased())
        }
        
        return distinct(rows.map(firstLetter))
            .reduce([Character: [Row]]()) {
                (acc: [Character: [Row]], letter: Character) -> [Character: [Row]] in
                var acc = acc
                acc[letter] = rows.filter {
                    (word) -> Bool in
                    firstLetter(word) == letter
                    }
                return acc
        }
    }
    
    func existsInInputHistory(_ row: Row) -> Bool {
        if (self.rows.filter {
                $0["candidate"] as! String == row["candidate"] as! String && $0["shuangpin"] as! String == row["shuangpin"] as! String
            }.isEmpty) {
            return false
        } else {
            return true
        }
    }
    
    func insertRowInDatabase(_ row: Row) {
        _inputHistoryDatabaseQueue.inDatabase() {
            db in
            let candidate = row["candidate"] as! String
            let shuangpin = row["shuangpin"] as! String
            if !(db?.executeUpdate("insert into history (candidate, shuangpin, shengmu, length, frequency, candidate_type) values (?, ?, ?, ?, ?, ?)", withArgumentsIn: [candidate, shuangpin, row["shengmu"] as! String, row["length"] as! Int, row["frequency"] as! Int, row["candidate_type"] as! Int]))! {
                print("insert 1 table failed: \(db?.lastErrorMessage()) \(candidate) \(shuangpin)")
            }
        }
    }
    
    func deleteRowInDatabase(_ row: Row) {
        _inputHistoryDatabaseQueue.inDatabase() {
            db in
            let candidate = row["candidate"] as! String
            let shuangpin = row["shuangpin"] as! String
            if !(db?.executeUpdate("delete from history where candidate == ? and shuangpin == ?", withArgumentsIn: [candidate, shuangpin]))! {
                print("delete 1 table failed: \(db?.lastErrorMessage()) \(candidate) \(shuangpin)")
            }
        }
    }
    
    lazy var _candidateDatabase: FMDatabase = {
        let databasePath = Bundle.main.path(forResource: "candidates", ofType: "sqlite")
        let database = FMDatabase(path: databasePath)
        if !(database?.open())! {
            assertionFailure("Unable to open database")
        }
        return database!
    }()
    
    func candidateTextIsInCandidatesDatabase(_ candidateText: String) -> Bool {
        if let rs = _candidateDatabase.executeQuery("select * from candidates where candidate == ?", withArgumentsIn: [candidateText]) {
            if rs.next() {
                return true
            } else {
                return false
            }
        } else {
            fatalError("select failed: \(_candidateDatabase.lastErrorMessage())")
        }
    }
    
    deinit {
        _inputHistoryDatabaseQueue!.close()
        _candidateDatabase.close()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func addCandidate() {
        let newRowIndex = rows.count
        
        let row = newRow(candidate: "SPi", shuangpin: "spi", shengmu: "s", length: 2, frequency: 1, candidate_type: 2)

        if existsInInputHistory(row) {
            return
        } else {
            rows.append(row)
            insertRowInDatabase(row)
            let indexPath = IndexPath(row: newRowIndex, section: 0)
            let indexPaths = [indexPath]
            tableView.insertRows(at: indexPaths,
                with: .automatic)
        }
    }
    
    func deleteCandidateInRow(_ indexPath: IndexPath) {
        if indexPath.row >= 0 && indexPath.row < rows.count {
            let rowToDelete = rowForIndexPath(indexPath)
            let indexName = indexNames[indexPath.section]
            let needDeleteSection = (rowIndex[indexName]!.count == 1)
            rows = rows.filter {
                (row: Row) -> Bool in
                return (row["candidate"] as! String != rowToDelete["candidate"] as! String
                    || row["shuangpin"] as! String != rowToDelete["shuangpin"] as! String)
            }
            deleteRowInDatabase(rowToDelete)
            if needDeleteSection {
                tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
            } else {
                let indexPaths = [indexPath]
                tableView.deleteRows(at: indexPaths, with: .automatic)
            }
        }
    }
    
    func newRow(candidate: String, shuangpin: String, shengmu: String, length: Int, frequency: Int, candidate_type: Int) -> Row {
        var row = Row()
        row["candidate"] = candidate
        row["shuangpin"] = shuangpin
        row["shengmu"] = shengmu
        row["length"] = length
        row["frequency"] = frequency
        row["candidate_type"] = candidate_type
        return row
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteCandidateInRow(indexPath)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
