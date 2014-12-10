
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerNib(UINib(nibName: "InputHistoryRowCell", bundle: nil), forCellReuseIdentifier: "inputHistoryRowCell")
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let documentsFolder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let databasePath = documentsFolder.stringByAppendingPathComponent("history.sqlite")
        
        let databaseQueue = FMDatabaseQueue(path: databasePath)
        
        if databaseQueue == nil {
            println("Unable to open database")
            return
        }
        
        databaseQueue?.inDatabase() {
            db in
            if let rs = db.executeQuery("select candidate, shuangpin, shengmu, length, frequency, candidate_type from history", withArgumentsInArray: nil) {
                while rs.next() {
                    self.rows.append(rs.resultDictionary())
                }
            } else {
                println("select failed: \(db.lastErrorMessage())")
            }
        }
        
        databaseQueue!.close()
        
        self.rows.sort {
            ($0["frequency"] as NSNumber).integerValue > ($1["frequency"] as NSNumber).integerValue
        }
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("inputHistoryRowCell", forIndexPath: indexPath) as InputHistoryRowCell

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
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
