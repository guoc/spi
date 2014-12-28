
import UIKit

class InputHistoryTableViewController: UITableViewController {

    var rows: [[NSObject: AnyObject]] = []
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
            tableView.registerNib(UINib(nibName: "AdvanceInputHistoryRowCell", bundle: nil), forCellReuseIdentifier: "advanceInputHistoryRowCell")
        } else {
            tableView.registerClass(InputHistoryRowCell.self, forCellReuseIdentifier: "inputHistoryRowCell")
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        rows = getAllRows()
        
        self.rows = self.rows.filter {
            self.candidateTextIsInCandidatesDatabase($0["candidate"] as String) == false
        }
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if enableAdvanceCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("advanceInputHistoryRowCell", forIndexPath: indexPath) as AdvanceInputHistoryRowCell
            let row = rows[indexPath.row]
            cell.candidateLabel.text = (row["candidate"] as String)
            cell.shuangpinLabel.text = (row["shuangpin"] as String)
            cell.shengmuLabel.text = (row["shengmu"] as String)
            cell.lengthLabel.text = String((row["length"] as NSNumber).integerValue)
            cell.frequencyLabel.text = String((row["frequency"] as NSNumber).integerValue)
            switch (row["candidate_type"] as NSNumber).integerValue {
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
            let cell = tableView.dequeueReusableCellWithIdentifier("inputHistoryRowCell", forIndexPath: indexPath) as InputHistoryRowCell
            let row = rows[indexPath.row]
            cell.textLabel?.text = row["candidate"] as? String
            cell.detailTextLabel?.text = row["shuangpin"] as? String
            return cell
        }
    }
    
    lazy var _inputHistoryDatabaseQueue: FMDatabaseQueue! = {
        let documentsFolder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let databasePath = documentsFolder.stringByAppendingPathComponent("history.sqlite")
        
        let databaseQueue = FMDatabaseQueue(path: databasePath)
        
        if databaseQueue == nil {
            println("Unable to open database")
        }
        
        return databaseQueue
    }()
    
    func getAllRows() -> [[NSObject: AnyObject]] {
        var rows: [[NSObject: AnyObject]] = []
        
        _inputHistoryDatabaseQueue.inDatabase() {
            db in
            if let rs = db.executeQuery("select candidate, shuangpin, shengmu, length, frequency, candidate_type from history", withArgumentsInArray: nil) {
                while rs.next() {
                    rows.append(rs.resultDictionary())
                }
            } else {
                println("select failed: \(db.lastErrorMessage())")
            }
        }
        
        rows.sort {
            ($0["frequency"] as NSNumber).integerValue > ($1["frequency"] as NSNumber).integerValue
        }
        
        return rows
    }
    
    func existsInInputHistory(row: [NSObject: AnyObject]) -> Bool {
        if (self.rows.filter {
                $0["candidate"] as String == row["candidate"] as String && $0["shuangpin"] as String == row["shuangpin"] as String
            }.isEmpty) {
            return false
        } else {
            return true
        }
    }
    
    func insertRowInDatabase(row: [NSObject: AnyObject]) {
        _inputHistoryDatabaseQueue.inDatabase() {
            db in
            let candidate = row["candidate"] as String
            let shuangpin = row["shuangpin"] as String
            if !db.executeUpdate("insert into history (candidate, shuangpin, shengmu, length, frequency, candidate_type) values (?, ?, ?, ?, ?, ?)", withArgumentsInArray: [candidate, shuangpin, row["shengmu"] as String, row["length"] as Int, row["frequency"] as Int, row["candidate_type"] as Int]) {
                println("insert 1 table failed: \(db.lastErrorMessage()) \(candidate) \(shuangpin)")
            }
        }
    }
    
    func deleteRowInDatabase(row: [NSObject: AnyObject]) {
        _inputHistoryDatabaseQueue.inDatabase() {
            db in
            let candidate = row["candidate"] as String
            let shuangpin = row["shuangpin"] as String
            if !db.executeUpdate("delete from history where candidate == ? and shuangpin == ?", withArgumentsInArray: [candidate, shuangpin]) {
                println("delete 1 table failed: \(db.lastErrorMessage()) \(candidate) \(shuangpin)")
            }
        }
    }
    
    lazy var _candidateDatabase: FMDatabase = {
        let databasePath = NSBundle.mainBundle().pathForResource("candidates", ofType: "sqlite")
        let database = FMDatabase(path: databasePath)
        if !database.open() {
            assertionFailure("Unable to open database")
        }
        return database
    }()
    
    func candidateTextIsInCandidatesDatabase(candidateText: String) -> Bool {
        if let rs = _candidateDatabase.executeQuery("select * from candidates where candidate == ?", withArgumentsInArray: [candidateText]) {
            if rs.next() {
                return true
            } else {
                return false
            }
        } else {
            assertionFailure("select failed: \(_candidateDatabase.lastErrorMessage())")
        }
    }
    
    deinit {
        _inputHistoryDatabaseQueue!.close()
        _candidateDatabase.close()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func addCandidate() {
        let newRowIndex = rows.count
        
        var row = newRow(candidate: "SPi", shuangpin: "spi", shengmu: "s", length: 2, frequency: 1, candidate_type: 2)

        if existsInInputHistory(row) {
            return
        } else {
            rows.append(row)
            insertRowInDatabase(row)
            let indexPath = NSIndexPath(forRow: newRowIndex, inSection: 0)
            let indexPaths = [indexPath]
            tableView.insertRowsAtIndexPaths(indexPaths,
                withRowAnimation: .Automatic)
        }
    }
    
    func deleteCandidateInRow(indexPath: NSIndexPath) {
        if indexPath.row >= 0 && indexPath.row < rows.count {
            let row = rows[indexPath.row]
            rows.removeAtIndex(indexPath.row)
            deleteRowInDatabase(row)
            let indexPaths = [indexPath]
            tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
        }
    }
    
    func newRow(#candidate: String, shuangpin: String, shengmu: String, length: Int, frequency: Int, candidate_type: Int) -> [NSObject: AnyObject] {
        var row = [NSObject: AnyObject]()
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
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            deleteCandidateInRow(indexPath)
        } else if editingStyle == .Insert {
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
