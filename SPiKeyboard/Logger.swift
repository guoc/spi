
import Foundation

private let _LoggerSharedInstance = Logger()

class Logger {
    class var sharedInstance: Logger {
        return _LoggerSharedInstance
    }
    
    let path = { () -> String in
        let folder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] 
        return URL(string: folder)!.appendingPathComponent("log").absoluteString
    }()
    
    var outputStream: OutputStream!
    
    init() {
        initOutputStream()
    }
    
    func initOutputStream() {
        outputStream = OutputStream(toFileAtPath: path, append: true)
        if outputStream != nil {
            outputStream.open()
        } else {
            assertionFailure("Unable to open file")
        }
    }
    
    deinit {
        outputStream.close()
    }
    
    func writeLogLine(selectedCellIndex: Int, selectedCellText: String) {
        writeLogLine(filledString: "@\(selectedCellIndex) \(selectedCellText)")
    }
    
    func writeLogLine(tappedKey: Key) {
        let tappedKeyText = tappedKey.uppercaseKeyCap ?? (tappedKey.lowercaseKeyCap ?? "???")
        writeLogLine(filledString: "\(tappedKeyText) <>")
    }
        
    func writeLogLine(filledString: String) {
        let currentTime = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .long
        let currentTimeStr = dateFormatter.string(from: currentTime)
        writeLogFileWith("\(filledString)\t\(currentTimeStr)\n")
    }
    
    func writeLogFileWith(_ string: String) {
        if !UserDefaults.standard.bool(forKey: "kLogging") {
            return
        }
        let qos = Int(DispatchQoS.QoSClass.background.rawValue)
        let queue = DispatchQueue.global(priority: qos)
        queue.async { () -> Void in
            self.outputStream.write(string)
            return
        }
    }
    
    func getLogFileContent() -> String {
        return (try? String(contentsOfFile: path, encoding: String.Encoding.utf8)) ?? "can not open log file"
    }
    
    func clearLogFile() {
        do {
            try FileManager.default.removeItem(atPath: path)
        } catch _ {
        }
        initOutputStream()
    }
    
    func getMemoryUsageReport() -> String {
        // from http://stackoverflow.com/questions/27556807/swift-pointer-problems-with-mach-task-basic-info/27559770#27559770
        
        // constant
        let MACH_TASK_BASIC_INFO_COUNT = (MemoryLayout<mach_task_basic_info_data_t>.size / MemoryLayout<natural_t>.size)
        
        // prepare parameters
        let name   = mach_task_self_
        let flavor = task_flavor_t(MACH_TASK_BASIC_INFO)
        var size   = mach_msg_type_number_t(MACH_TASK_BASIC_INFO_COUNT)
        
        // allocate pointer to mach_task_basic_info
        let infoPointer = UnsafeMutablePointer<mach_task_basic_info>.allocate(capacity: 1)
        
        // call task_info - note extra UnsafeMutablePointer(...) call
        let kerr = task_info(name, flavor, UnsafeMutablePointer(infoPointer), &size)
        
        // get mach_task_basic_info struct out of pointer
        let info = infoPointer.move()
        
        // deallocate pointer
        infoPointer.deallocate(capacity: 1)
        
        // check return value for success / failure
        if kerr == KERN_SUCCESS {
            let numberFormatter = NumberFormatter()
            numberFormatter.groupingSize = 3
            numberFormatter.groupingSeparator = ","
            numberFormatter.usesGroupingSeparator = true
            let usageStr = numberFormatter.string(from: NSNumber(value: info.resident_size as UInt64)) ?? "not available"
            return ("Memory in use (in bytes): \(usageStr)")
        } else {
            let errorString = String(CString: mach_error_string(kerr), encoding: String.Encoding.ascii)
            return (errorString ?? "Error: couldn't parse error string")
        }
    }
}

extension OutputStream {
    
    /// Write String to outputStream
    ///
    /// - parameter string:                The string to write.
    /// - parameter encoding:              The NSStringEncoding to use when writing the string. This will default to UTF8.
    /// - parameter allowLossyConversion:  Whether to permit lossy conversion when writing the string.
    ///
    /// - returns:                     Return total number of bytes written upon success. Return -1 upon failure.
    
    func write(_ string: String, encoding: String.Encoding = String.Encoding.utf8, allowLossyConversion: Bool = true) -> Int {
        if let data = string.data(using: encoding, allowLossyConversion: allowLossyConversion) {
            var bytes = (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count)
            var bytesRemaining = data.count
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
