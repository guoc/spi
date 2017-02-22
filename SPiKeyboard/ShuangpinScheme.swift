
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
        let schemeName = UserDefaults.standard.string(forKey: "kScheme") ?? "自然码"
        let path = Bundle.main.path(forResource: schemeName, ofType: "spscheme")
        if FileManager.default.fileExists(atPath: path!) {
            _scheme = NSDictionary(contentsOfFile: path!) as! [String: String]!
        } else {
            print("scheme is not found")
        }
    }
    
    class func reloadScheme() {
        ShuangpinScheme.loadScheme()
    }
}
