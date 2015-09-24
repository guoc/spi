
import Foundation

private let _LoggerSharedInstance = Logger()

class Logger {
    class var sharedInstance: Logger {
        return _LoggerSharedInstance
    }
    
    let path = { () -> String in
        let folder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
        return NSURL(string: folder)!.URLByAppendingPathComponent("log").absoluteString
    }()
    
    var outputStream: NSOutputStream!
    
    init() {
        initOutputStream()
    }
    
    func initOutputStream() {
        outputStream = NSOutputStream(toFileAtPath: path, append: true)
        if outputStream != nil {
            outputStream.open()
        } else {
            assertionFailure("Unable to open file")
        }
    }
    
    deinit {
        outputStream.close()
    }
    
    func writeLogLine(selectedCellIndex selectedCellIndex: Int, selectedCellText: String) {
        writeLogLine(filledString: "@\(selectedCellIndex) \(selectedCellText)")
    }
    
    func writeLogLine(tappedKey tappedKey: Key) {
        let tappedKeyText = tappedKey.uppercaseKeyCap ?? (tappedKey.lowercaseKeyCap ?? "???")
        writeLogLine(filledString: "\(tappedKeyText) <>")
    }
        
    func writeLogLine(filledString filledString: String) {
        let currentTime = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .LongStyle
        let currentTimeStr = dateFormatter.stringFromDate(currentTime)
        writeLogFileWith("\(filledString)\t\(currentTimeStr)\n")
    }
    
    func writeLogFileWith(string: String) {
        if !NSUserDefaults.standardUserDefaults().boolForKey("kLogging") {
            return
        }
        let qos = Int(QOS_CLASS_BACKGROUND.rawValue)
        let queue = dispatch_get_global_queue(qos, 0)
        dispatch_async(queue) { () -> Void in
            self.outputStream.write(string)
            return
        }
    }
    
    func getLogFileContent() -> String {
        return (try? String(contentsOfFile: path, encoding: NSUTF8StringEncoding)) ?? "can not open log file"
    }
    
    func clearLogFile() {
        do {
            try NSFileManager.defaultManager().removeItemAtPath(path)
        } catch _ {
        }
        initOutputStream()
    }
    
    func getMemoryUsageReport() -> String {
        // from http://stackoverflow.com/questions/27556807/swift-pointer-problems-with-mach-task-basic-info/27559770#27559770
        
        // constant
        let MACH_TASK_BASIC_INFO_COUNT = (sizeof(mach_task_basic_info_data_t) / sizeof(natural_t))
        
        // prepare parameters
        let name   = mach_task_self_
        let flavor = task_flavor_t(MACH_TASK_BASIC_INFO)
        var size   = mach_msg_type_number_t(MACH_TASK_BASIC_INFO_COUNT)
        
        // allocate pointer to mach_task_basic_info
        let infoPointer = UnsafeMutablePointer<mach_task_basic_info>.alloc(1)
        
        // call task_info - note extra UnsafeMutablePointer(...) call
        let kerr = task_info(name, flavor, UnsafeMutablePointer(infoPointer), &size)
        
        // get mach_task_basic_info struct out of pointer
        let info = infoPointer.move()
        
        // deallocate pointer
        infoPointer.dealloc(1)
        
        // check return value for success / failure
        if kerr == KERN_SUCCESS {
            let numberFormatter = NSNumberFormatter()
            numberFormatter.groupingSize = 3
            numberFormatter.groupingSeparator = ","
            numberFormatter.usesGroupingSeparator = true
            let usageStr = numberFormatter.stringFromNumber(NSNumber(unsignedLongLong: info.resident_size)) ?? "not available"
            return ("Memory in use (in bytes): \(usageStr)")
        } else {
            let errorString = String(CString: mach_error_string(kerr), encoding: NSASCIIStringEncoding)
            return (errorString ?? "Error: couldn't parse error string")
        }
    }
}

extension NSOutputStream {
    
    /// Write String to outputStream
    ///
    /// - parameter string:                The string to write.
    /// - parameter encoding:              The NSStringEncoding to use when writing the string. This will default to UTF8.
    /// - parameter allowLossyConversion:  Whether to permit lossy conversion when writing the string.
    ///
    /// - returns:                     Return total number of bytes written upon success. Return -1 upon failure.
    
    func write(string: String, encoding: NSStringEncoding = NSUTF8StringEncoding, allowLossyConversion: Bool = true) -> Int {
        if let data = string.dataUsingEncoding(encoding, allowLossyConversion: allowLossyConversion) {
            var bytes = UnsafePointer<UInt8>(data.bytes)
            var bytesRemaining = data.length
            var totalBytesWritten = 0
            
            while bytesRemaining > 0 {
                let bytesWritten = self.write(bytes, maxLength: bytesRemaining)
                if bytesWritten < 0 {
                    return -1
                }
                
                bytesRemaining -= bytesWritten
                bytes += bytesWritten
                totalBytesWritten += bytesWritten
            }
            
            return totalBytesWritten
        }
        
        return -1
    }
    
}
