
import Foundation

private var _scheme: [String: String]? = nil

class ShuangpinScheme {
    
    class func getScheme() -> [String: String] {
        if _scheme == nil {
            ShuangpinScheme.loadScheme()
        }
        return _scheme!
    }
    
    class func loadScheme() {
        let schemeName = NSUserDefaults.standardUserDefaults().stringForKey("scheme") ?? "自然码"
        let path = NSBundle.mainBundle().pathForResource(schemeName, ofType: "spscheme")
        if NSFileManager.defaultManager().fileExistsAtPath(path!) {
            _scheme = NSDictionary(contentsOfFile: path!) as [String: String]!
        } else {
            println("scheme is not found")
        }
    }
    
    class func reloadScheme() {
        ShuangpinScheme.loadScheme()
    }
}