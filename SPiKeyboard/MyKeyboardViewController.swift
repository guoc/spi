
import UIKit

var showTypingCellInExtraLine = getShowTypingCellInExtraLineFromSettings()

func updateShowTypingCellInExtraLine() {
    showTypingCellInExtraLine = getShowTypingCellInExtraLineFromSettings()
}

func getShowTypingCellInExtraLineFromSettings() -> Bool {
    return UserDefaults.standard.bool(forKey: "kShowTypingCellInExtraLine")    // If not exist, false will be returned.
}

func getEnableGestureFromSettings() -> Bool {
    return UserDefaults.standard.bool(forKey: "kGesture")    // If not exist, false will be returned.
}

var cornerBracketEnabled = getCornerBracketEnabledFromSettings()

func updateCornerBracketEnabled() {
    cornerBracketEnabled = getCornerBracketEnabledFromSettings()
}

func getCornerBracketEnabledFromSettings() -> Bool {
    return UserDefaults.standard.bool(forKey: "kCornerBracket")    // If not exist, false will be returned.
}

var candidatesBannerAppearanceIsDark = false

let indexPathZero = IndexPath(row: 0, section: 0)
let indexPathFirst = IndexPath(row: 1, section: 0)

var startTime: Date?

class MyKeyboardViewController: KeyboardViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, IASKSettingsDelegate, ForwardingViewDelegate {

    let candidatesDataModel = CandidatesDataModel()

    var candidatesBanner: CandidatesBanner?
    
    var candidatesUpdateQueue: CandidatesUpdateQueue!
    
    var ignoreKeyPressOnce: Bool = false
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        Logger.sharedInstance.writeLogLine(filledString: "<<<<<<<<<\n")
        
        self.forwardingView.delegate = self
        self.candidatesUpdateQueue = CandidatesUpdateQueue(controller: self)
        NotificationCenter.default.addObserver(self, selector: #selector(settingDidChange(_:)), name: NSNotification.Name(rawValue: "kAppSettingChanged"), object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        Logger.sharedInstance.writeLogLine(filledString: ">>>>>>>>>\n")
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func insertCandidateAutomaticallyIfNecessary() {
        if let candidate = candidatesDataModel.getTypingCompleteCachedCandidate() {
            self.textDocumentProxy.insertText(candidate)
            candidatesDataModel.typingString.reset()
            candidatesDataModel.updateDataModelRaisedByTypingChange()
        }
    }
    
    func updateBannerHeight() {
        
        func changeBannerIfNecessary(newHeight: CGFloat) {
            if metric("topBanner") != newHeight {
                changeBannerHeight(newHeight)
                candidatesBanner?.resetSubviewsWithInitAndSetDelegate()
            }
        }
        
        changeBannerIfNecessary(newHeight: (showTypingCellInExtraLine ? bannerHeightWhenShowTypingCellInExtraLineIsTrue : bannerHeightWhenShowTypingCellInExtraLineIsFalse))
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        if UserDefaults.standard.bool(forKey: "kLogging") {
            let memoryUsageReport = Logger.sharedInstance.getMemoryUsageReport()
            self.textDocumentProxy.insertText("MEMORY LOW")
            Logger.sharedInstance.writeLogLine(filledString: "!!!!!!!!!\n! \(memoryUsageReport)")
        }
    }
    
    override func keyPressed(_ key: Key) {
        /* Make sure the implementation is same as its super class' function except the folloing part */
        /* For this function, it's all part */
        /* Original implementation
        if let proxy = (self.textDocumentProxy as? UIKeyInput) {
            proxy.insertText(key.outputForCase(self.shiftState.uppercase()))
        }
        */
        
        Logger.sharedInstance.writeLogLine(tappedKey: key)
        
        if ignoreKeyPressOnce {
            ignoreKeyPressOnce = false
            return
        }
        
        // Scroll back to first candidate
        candidatesBanner!.scrollToFirstCandidate()
                
        if key.type == .space {
            if candidatesDataModel.hasTyping() {
                if candidatesDataModel.textAt(indexPathFirst) != nil {
                    candidatesUpdateQueue.selectCandidate(indexPathFirst)
                } else {
                    let typingStringAsCandidate = candidatesDataModel.getUserTypingString()
                    self.textDocumentProxy.insertText(typingStringAsCandidate)
                    candidatesUpdateQueue.selectCandidate(indexPathZero)
                }
            } else {
                // Insert Space
                self.textDocumentProxy.insertText(key.outputForCase(self.shiftState.uppercase()))
            }
            return
        } else if key.type == .return {
            if candidatesDataModel.hasTyping() {
                let typingStringAsCandidate = candidatesDataModel.getUserTypingString()
                self.textDocumentProxy.insertText(typingStringAsCandidate)
                candidatesUpdateQueue.selectCandidate(indexPathZero)
            } else {
                // Insert Return
                self.textDocumentProxy.insertText(key.outputForCase(self.shiftState.uppercase()))
            }
        } else if key.type == .character {    // Letters
            candidatesUpdateQueue.appendTyping(key.outputForCase(self.shiftState.uppercase()))
        } else {    // Special characters
            if candidatesDataModel.hasTyping() {
                candidatesUpdateQueue.appendTyping(key.outputForCase(self.shiftState.uppercase()))
            } else {
                self.textDocumentProxy.insertText(key.outputForCase(self.shiftState.uppercase()))
            }
        }
        /* */
    }
    
    override func keyPressedHelper(_ sender: KeyboardKey) {
        super.keyPressedHelper(sender)    // keyPressed is called in super.keyPressedHelper
        if candidatesDataModel.hasTyping() {
            autoPeriodState = .noSpace
        }
    }
    
    var isDeletingTyping = false
    
    override func backspaceDown(_ sender: KeyboardKey) {
        self.cancelBackspaceTimers()
        
        /* Make sure the implementation is same as its super class' function except the folloing part */
        /* Original implementation
        if let textDocumentProxy = self.textDocumentProxy as? UIKeyInput {
        textDocumentProxy.deleteBackward()
        }
        */
        
        Logger.sharedInstance.writeLogLine(filledString: "[DELETE] <")
        
        isDeletingTyping = false    // Reset
        if candidatesDataModel.hasTyping() {
            candidatesUpdateQueue.deleteBackwardTyping()
        } else {
            textDocumentProxy.deleteBackward()
        }
        /* */
        
        // trigger for subsequent deletes
        self.backspaceDelayTimer = Timer.scheduledTimer(timeInterval: backspaceDelay - backspaceRepeat, target: self, selector: #selector(backspaceDelayCallback), userInfo: nil, repeats: false)
    }
    
    override func backspaceUp(_ sender: KeyboardKey) {
        super.backspaceUp(sender)
        
        Logger.sharedInstance.writeLogLine(filledString: "[DELETE] >")
    }
    
    override func backspaceRepeatCallback() {
        self.playKeySound()
        
        /* Make sure the implementation is same as its super class' function except the folloing part */
        /* Original implementation
        if let textDocumentProxy = self.textDocumentProxy as? UIKeyInput {
            textDocumentProxy.deleteBackward()
        }
        */
        if candidatesDataModel.hasTyping() {
            isDeletingTyping = true
            candidatesUpdateQueue.deleteBackwardTyping()
        } else {
            if isDeletingTyping == false {
                textDocumentProxy.deleteBackward()
            }
        }
        /* */
    }
    
    override func shiftDown(_ sender: KeyboardKey) {
        super.shiftDown(sender)
        
        Logger.sharedInstance.writeLogLine(filledString: "[SHIFT] <")
    }
    
    override func shiftUp(_ sender: KeyboardKey) {
        super.shiftUp(sender)
        
        Logger.sharedInstance.writeLogLine(filledString: "[SHIFT] >")
    }
    
    override func shiftDoubleTapped(_ sender: KeyboardKey) {
        super.shiftDoubleTapped(sender)
        
        Logger.sharedInstance.writeLogLine(filledString: "[SHIFT] <><")
    }
    
    override func modeChangeTapped(_ sender: KeyboardKey) {
        let tappedKeyText = sender.label.text ?? "[MODE] ???"
        
        super.modeChangeTapped(sender)

        Logger.sharedInstance.writeLogLine(filledString: "[\(tappedKeyText)] <>")
    }
    
    override func advanceTapped(_ sender: KeyboardKey) {
        super.advanceTapped(sender)
        
        Logger.sharedInstance.writeLogLine(filledString: "[NEXT IM]")
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        Logger.sharedInstance.writeLogLine(selectedCellIndex: indexPath.row, selectedCellText: (collectionView.cellForItem(at: indexPath) as! CandidateCell).textLabel.text!)
        
        if indexPath == indexPathZero {
            if candidatesDataModel.hasTyping() {
                if candidatesDataModel.typingString.hasSelectedPartialCandidates() {
                    let displayedTypingStringAsCandidate = candidatesDataModel.textAt(indexPathZero)
                    self.textDocumentProxy.insertText(displayedTypingStringAsCandidate!)
                    candidatesUpdateQueue.selectCandidate(indexPathZero)
                } else {
                    let typingStringAsCandidate = candidatesDataModel.getUserTypingString()
                    self.textDocumentProxy.insertText(typingStringAsCandidate)
                    candidatesUpdateQueue.selectCandidate(indexPathZero)
                }
            }
        } else {
            let _ = candidatesDataModel.textAt(indexPath)!
            candidatesUpdateQueue.selectCandidate(indexPath)
        }
    }
        
    func changeBannerHeight(_ height: CGFloat) {
        metrics["topBanner"] = Double(height)
        
        self.keyboardHeight = self.heightForOrientation(self.interfaceOrientation, withTopBanner: true)
    }
    
    override func createBanner() -> ExtraView? {
        
        candidatesBanner = CandidatesBanner(globalColors: type(of: self).globalColors, darkMode: false, solidColorMode: self.solidColorMode())
        candidatesBanner!.delegate = self
        
        return candidatesBanner
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return candidatesDataModel.numberOfTypingAndCandidates()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CandidateCell
        cell.updateAppearance()
        if (indexPath == indexPathZero) {
            cell.textLabel.textAlignment = .left
        } else {
            cell.textLabel.textAlignment = .center
        }
        cell.textLabel.text = candidatesDataModel.textAt(indexPath)
//        cell.textLabel.sizeToFit()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return getCellSizeAtIndex(indexPath, inDataModel: candidatesDataModel, andSetLayout: collectionViewLayout as! UICollectionViewFlowLayout)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        candidatesBanner!.setCollectionViewFrame(CGRect(x: 0, y: 0, width: self.view.bounds.width, height: candidateCellHeight))
    }
    
    func getCellSizeAtIndex(_ indexPath: IndexPath, inDataModel dataModel: CandidatesDataModel, andSetLayout layout: UICollectionViewFlowLayout) -> CGSize {
        let size = CandidateCell.getCellSizeByText(dataModel.textAt(indexPath)!, needAccuracy: indexPath == indexPathZero ? true : false)
        if let myLayout = layout as? MyCollectionViewFlowLayout {
            myLayout.updateLayoutRaisedByCellAt(indexPath, withCellSize: size)
        }
        return size
    }
    
    func resetLayoutWithDataModel() {
        var allCellSize = candidatesDataModel.allText().map({CandidateCell.getCellSizeByText($0, needAccuracy: false)})
        allCellSize[0] = CandidateCell.getCellSizeByText(candidatesDataModel.textAt(indexPathZero)!, needAccuracy: true)
        candidatesBanner!.resetLayoutWithAllCellSize(allCellSize)
    }
    
    func onlyUpdateTyping() {
        let size = CandidateCell.getCellSizeByText(candidatesDataModel.textAt(indexPathZero)!, needAccuracy: true)
        let typingIndex = indexPathZero
        candidatesBanner!.updateCellAt(typingIndex, withCellSize: size)
    }
    
    // For candidates banner scroll
    var nextPageStartX: CGFloat = 0
    var previousPageStartX: CGFloat = 0
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

        let collectionView = scrollView as! UICollectionView
        let visibleItems = collectionView.indexPathsForVisibleItems
    
        if scrollView.isKindOfMyCollectionViewFlowLayout() == false {    // For candidates table scroll
            
            return
            
        } else {    // For candidates banner scroll
        
            let mostLeftCellIndexPathRow = visibleItems.reduce(Int.max) {
                min($0, $1.row)
            }
            
            let mostRightCellIndexPathRow = visibleItems.reduce(Int.min) {
                max($0, $1.row)
            }
            
            let mostLeftCellIndexPath = IndexPath(item: mostLeftCellIndexPathRow, section: 0)
            var mostRightCellIndexPath = IndexPath(item: mostRightCellIndexPathRow, section: 0)
            
            // Avoid wrong calculation when candidate cell is wider than the width of collectionView
            let collectionViewBoundsX = collectionView.bounds.origin.x
            if collectionView.layoutAttributesForItem(at: mostRightCellIndexPath)!.frame.minX <= (collectionViewBoundsX > 0 ? collectionViewBoundsX : 0) {    // Expression "? :" for the case when collectionViewBoundsX < 0 because of inset
                if mostRightCellIndexPath.row + 1 < collectionView.numberOfItems(inSection: 0) {
                    mostRightCellIndexPath = IndexPath(item: mostRightCellIndexPath.row + 1, section: 0)
                }
            }
            
            nextPageStartX = collectionView.layoutAttributesForItem(at: mostRightCellIndexPath)!.frame.minX
            
            let maxXOfMostLeftCell = collectionView.layoutAttributesForItem(at: mostLeftCellIndexPath)!.frame.maxX
            var indexPath: IndexPath! = mostLeftCellIndexPath
            while collectionView.layoutAttributesForItem(at: indexPath)!.frame.minX + collectionView.bounds.width >= maxXOfMostLeftCell {
                if indexPath.row - 1 < 0 {
                    break
                } else {
                    indexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
                }
            }
            
            if indexPath.row == mostLeftCellIndexPath.row {
                // Avoid wrong calculation when candidate cell is wider than the width of collectionView
                if indexPath.row - 1 < 0 {
                    indexPath = indexPathZero
                } else {
                    indexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
                }
            } else {
                if indexPath.row - 1 < 0 {
                    indexPath = indexPathZero
                } else {
                    indexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
                }
            }
            
            previousPageStartX = collectionView.layoutAttributesForItem(at: indexPath)!.frame.minX
            
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView.isKindOfMyCollectionViewFlowLayout() == false {    // For candidates table scroll
            
            return
            
        } else {    // For candidates banner scroll
            
            assert(previousPageStartX < nextPageStartX, "Calculate wrong pages start")
            if targetContentOffset.pointee.x > nextPageStartX {
                targetContentOffset.pointee.x = nextPageStartX
            }
            if targetContentOffset.pointee.x < previousPageStartX {
                targetContentOffset.pointee.x = previousPageStartX
            }
            
        }
    }
    
    func updateCandidatesBanner() {
        resetLayoutWithDataModel()
        candidatesBanner!.reloadData()
    }
    
    func updateTypingText() {
        let size = CandidateCell.getCellSizeByText(candidatesDataModel.textAt(indexPathZero)!, needAccuracy: true)
        candidatesBanner!.collectionViewLayout.updateLayoutRaisedByCellAt(indexPathZero, withCellSize: size)
    }
    
    // KeyboardViewController
    override func updateAppearances(_ appearanceIsDark: Bool) {
        candidatesBannerAppearanceIsDark = appearanceIsDark
        candidatesUpdateQueue.resetTyping()
        super.updateAppearances(appearanceIsDark)
        candidatesBanner?.updateAppearance()
    }
    
    var currentOrientation: UIInterfaceOrientation? = nil
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        super.willRotate(to: toInterfaceOrientation, duration: duration)
        if currentOrientation == nil || currentOrientation! != toInterfaceOrientation {
            switch(toInterfaceOrientation) {
            case .unknown, .portrait, .portraitUpsideDown:
                candidatesBanner?.removeConstraints(candidatesBanner!.landscapeBannerWidthConstraints!)
                candidatesBanner?.addConstraints(candidatesBanner!.potraitBannerWidthConstraints!)
            case .landscapeLeft, .landscapeRight:
                candidatesBanner?.removeConstraints(candidatesBanner!.potraitBannerWidthConstraints!)
                candidatesBanner?.addConstraints(candidatesBanner!.landscapeBannerWidthConstraints!)
            }
        }
        currentOrientation = toInterfaceOrientation
    }
    
    var needDismissKeyboard = false
    func settingDidChange(_ notification: Notification) {
        needDismissKeyboard = true
        if ((notification.object as AnyObject).isEqual("kShowTypingCellInExtraLine")) {
            updateShowTypingCellInExtraLine()
            self.updateBannerHeight()
        }
        if ((notification.object as AnyObject).isEqual("kCornerBracket")) {
            updateCornerBracketEnabled()
        }
    }
    
    fileprivate func outputUserHistory() {
        let documentsFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] 
        let historyDatabasePath = URL(string: documentsFolder)!.appendingPathComponent("history.sqlite")
        
        let historyDatabase = FMDatabase(path: historyDatabasePath.absoluteString)
        
        if !(historyDatabase?.open())! {
            print("Unable to open database")
            return
        }
        
        let candidatesDatabasePath = Bundle.main.path(forResource: "candidates", ofType: "sqlite")
        let candidatesDatabase = FMDatabase(path: candidatesDatabasePath)
        if !(candidatesDatabase?.open())! {
            assertionFailure("Unable to open database")
        }
        
        var rows: [Row] = []
        
        if let rs = historyDatabase?.executeQuery("select candidate, shuangpin, shengmu, length, frequency, candidate_type from history order by shengmu", withArgumentsIn: nil) {
            while rs.next() {
                let row = rs.resultDictionary()
                if let rs = candidatesDatabase?.executeQuery("select * from candidates where candidate == ?", withArgumentsIn: [row?["candidate"] as! String]) {
                    if !rs.next() {
                        rows.append(row! as Row)
                    }
                } else {
                    fatalError("select failed: \(candidatesDatabase?.lastErrorMessage())")
                }
                
            }
        } else {
            print("select failed: \(historyDatabase?.lastErrorMessage())")
        }
        
        let orderedRows: [Row] = rows.sorted { (lhs: Row, rhs: Row) -> Bool in
            return (lhs["frequency"] as! NSNumber).intValue > (rhs["frequency"] as! NSNumber).intValue
        }
        
        for row in orderedRows {
            let shuangpin = row["shuangpin"] as! String
            let shengmu = row["shengmu"] as! String
            let length = row["length"] as! Int
            let frequency = row["frequency"] as! Int
            let candidate = row["candidate"] as! String
            let candidateType = row["candidate_type"] as! Int
            self.textDocumentProxy.insertText("\(candidate),\(shuangpin),\(shengmu),\(length),\(frequency),\(candidateType);")
        }
        
        historyDatabase?.close()
        candidatesDatabase?.close()
    }

    fileprivate func run_command(_ commandStr: String) {
        switch commandStr {
        case "crash":
            func crash() {
                var a = 0
                a = a + 10
                let arr = [1,2,3]
                let _ = arr[10]
            }
            crash()
        case "export":
            outputUserHistory()
        case "import":
            var imported = false
            let previousContext = self.textDocumentProxy.documentContextBeforeInput
            if previousContext != nil {
                let historyLine = previousContext!
                let historyCandidates = historyLine.characters.split { $0 == ";" }.map { String($0) }
                for candidate in historyCandidates {
                    let candidateParts = candidate.characters.split { $0 == "," }.map { String($0) }
                    if candidateParts.count == 6 {
                        let candidateText = candidateParts[0]
                        let shuangpin = candidateParts[1]
                        let shengmu = candidateParts[2]
                        let length: Int? = Int(candidateParts[3])
                        let frequency: Int? = Int(candidateParts[4])
                        let candidateType: Int? = Int(candidateParts[5])
                        if length != nil && frequency != nil && candidateType != nil {
                            candidatesDataModel.inputHistory.updateDatabase(candidateText: candidateText, shuangpin: shuangpin, shengmu: shengmu, length: NSNumber(value: length! as Int), frequency: NSNumber(value: frequency! as Int), candidateType: String(candidateType!))
                            imported = true
                        } else {
                            imported = false
                        }
                    } else {
                        imported = false
                        break
                    }
                }
            }
            if imported == true {
                self.textDocumentProxy.insertText("导入成功 :]]")
            } else {
                self.textDocumentProxy.insertText("导入失败 :[[")
            }
        case "clean":
            candidatesDataModel.inputHistory.cleanAllCandidates()
        case "turnonlog":
            UserDefaults.standard.set(true, forKey: "kLogging")
        case "turnofflog":
            UserDefaults.standard.set(false, forKey: "kLogging")
        case "log":
            let logString = Logger.sharedInstance.getLogFileContent()
            self.textDocumentProxy.insertText(logString)
        case "memory":
            let memoryUsageReport = Logger.sharedInstance.getMemoryUsageReport()
            self.textDocumentProxy.insertText(memoryUsageReport)
        case "cllog":
            Logger.sharedInstance.clearLogFile()
        default:
            break
        }
    }
    
    @IBAction override func toggleSettings() {
        Logger.sharedInstance.writeLogLine(filledString: "[SETTINGS] <>")
        
        let typingBeforeToggleSettings = candidatesDataModel.typingString.userTypingString
        candidatesUpdateQueue.resetTyping()
        if typingBeforeToggleSettings != "" {
            let lastCharacter = typingBeforeToggleSettings[typingBeforeToggleSettings.characters.index(before: typingBeforeToggleSettings.endIndex)]
            switch lastCharacter {
            case "+":
                if let documentContextAfterInput = (self.textDocumentProxy ).documentContextAfterInput {
                    if typingBeforeToggleSettings != "" && documentContextAfterInput != "" {
                        let candidateTextLength = documentContextAfterInput.getReadingLength()
                        (self.textDocumentProxy ).adjustTextPosition(byCharacterOffset: candidateTextLength)
                        for _ in 0..<candidateTextLength {
                            textDocumentProxy.deleteBackward()
                        }
                        let initStr = typingBeforeToggleSettings.substring(to: typingBeforeToggleSettings.characters.index(before: typingBeforeToggleSettings.endIndex))
                        candidatesDataModel.inputHistory.updateDatabase(candidateText: documentContextAfterInput, customCandidateQueryString: initStr)
                        candidatesUpdateQueue.resetTyping()
                        return
                    } else {
                        
                    }
                } else {
                    
                }
            case "!":
                let initStr = typingBeforeToggleSettings.substring(to: typingBeforeToggleSettings.characters.index(before: typingBeforeToggleSettings.endIndex))
                run_command(initStr)
                return
            default:
                break
            }
        } else {
            
        }
        
        var hideInputHistory = true
        if currentMode == 2 {
            currentMode = 0
            hideInputHistory = false
        } else {
            hideInputHistory = true
        }
        
        let keyboardSettingsViewController = IASKAppSettingsViewController()
        keyboardSettingsViewController.delegate = self
        let aNavController = UINavigationController(rootViewController: keyboardSettingsViewController)
        keyboardSettingsViewController.showCreditsFooter = false
        keyboardSettingsViewController.showDoneButton = true
        keyboardSettingsViewController.hiddenKeys = hideInputHistory ? Set(["kInputHistory", "kGesture", "kGestureComment"]) : nil
        self.present(aNavController, animated: true, completion: nil)
    }
    
    func settingsViewControllerDidEnd(_ sender: IASKAppSettingsViewController!) {
        if self.needDismissKeyboard == true {
            self.dismissKeyboard()    // Dismiss keyboard to reload candidates banner appearance.
        }
        self.needDismissKeyboard = false
        
        self.dismiss(animated: true, completion: nil)
        
        ShuangpinScheme.reloadScheme()
    }
    
    override func shouldAutoCapitalize() -> Bool {
        return false
    }
    
    var isShowingCandidatesTable = false
    @IBAction func toggleCandidatesTableOrDismissKeyboard() {
        if !candidatesDataModel.hasTyping() {
            Logger.sharedInstance.writeLogLine(filledString: "[DOWN] <> DISMISS")
            self.dismissKeyboard()
            return
        }
        if isShowingCandidatesTable == false {
            Logger.sharedInstance.writeLogLine(filledString: "[DOWN] <>")
            isShowingCandidatesTable = true
            showCandidatesTable()
        } else {
            Logger.sharedInstance.writeLogLine(filledString: "[UP] <>")
            isShowingCandidatesTable = false
            exitCandidatesTable()
        }
    }
    
    var candidatesTable: UICollectionView!
    func showCandidatesTable() {
        isShowingCandidatesTable = true
        candidatesBanner!.hideTypingAndCandidatesView()
        candidatesBanner!.changeArrowUp()
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        candidatesTable = UICollectionView(frame: CGRect(x: view.frame.origin.x, y: view.frame.origin.y + getBannerHeight(), width: view.frame.width, height: view.frame.height - getBannerHeight()), collectionViewLayout: layout)
        candidatesTable.backgroundColor = candidatesBannerAppearanceIsDark ? UIColor.darkGray : UIColor.white
        candidatesTable.register(CandidateCell.self, forCellWithReuseIdentifier: "Cell")
        candidatesTable.delegate = self
        candidatesTable.dataSource = self
        self.view.addSubview(candidatesTable)
    }
    
    func exitCandidatesTable() {
        isShowingCandidatesTable = false
        candidatesBanner!.scrollToFirstCandidate()
        candidatesBanner!.unhideTypingAndCandidatesView()
        candidatesBanner!.changeArrowDown()
        candidatesTable.removeFromSuperview()
    }
    
    func exitCandidatesTableIfNecessary() {
        if isShowingCandidatesTable == false {
            return
        }
        exitCandidatesTable()
    }
    
    fileprivate func commandForKey(_ key: Key) -> (() -> ())? {
        if let character = key.lowercaseOutput {
            switch(character) {
            case "d":
                return { () in return
                    self.candidatesDataModel.inputHistory.deleteRecentCandidate()
                }
            default:
                return nil
            }
        } else {
            return nil
        }
    }
    
    func didPan(from beginView: UIView, to endView: UIView) {
        if getEnableGestureFromSettings() == false {
            return
        }
        if let beginKeyView = beginView as? KeyboardKey {
            if let beginKey = self.layout?.keyForView(beginKeyView) {
                if beginKey.type == .space {
                    if let endKeyView = endView as? KeyboardKey {
                        if let endKey = self.layout?.keyForView(endKeyView) {
                            if endKey.type != .space {
                                if let command = commandForKey(endKey) {
                                    if endKey.hasOutput {
                                        ignoreKeyPressOnce = true
                                    }
                                    command()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Logger.sharedInstance.writeLogLine(filledString: "--------- VDL\n")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.inputView?.setNeedsUpdateConstraints()
        
        Logger.sharedInstance.writeLogLine(filledString: "--------- VDA\n")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Logger.sharedInstance.writeLogLine(filledString: "--------- VDDA\n")
    }
    
}

class CandidatesUpdateQueue {
    
    lazy var candidatesUpdateQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Candidates update queue"
        queue.maxConcurrentOperationCount = 1
        return queue
        }()
    let controller: MyKeyboardViewController
    
    init(controller: MyKeyboardViewController) {
        self.controller = controller
    }
    
    func appendTyping(_ text: String) {
//        objc_sync_enter(self.controller.candidatesDataModel)
//        objc_sync_enter(self.controller.collectionViewLayout)
//        
//        dispatch_async(dispatch_get_main_queue(), {
            self.controller.candidatesDataModel.appendTypingStringBy(text, needCandidatesUpdate: false)
//            self.controller.resetLayoutWithDataModel()
//            self.controller.collectionView!.reloadData()
//        })
//        objc_sync_exit(self.controller.collectionViewLayout)
//        objc_sync_exit(self.controller.candidatesDataModel)
        candidatesUpdateQueue.cancelAllOperations()
        addCommonUpdateOperation(controller: controller)
    }
    
    func deleteBackwardTyping() {
        self.controller.candidatesBanner!.scrollToFirstCandidate()
        self.controller.candidatesDataModel.deleteBackwardTyping(needCandidatesUpdate: false)
        candidatesUpdateQueue.cancelAllOperations()
        addCommonUpdateOperation(controller: controller)
    }
    
    func selectCandidate(_ selectedCandidateIndexPath: IndexPath) {
        self.controller.setMode(0)
        self.controller.exitCandidatesTableIfNecessary()
        self.controller.candidatesBanner!.scrollToFirstCandidate()
        self.controller.candidatesDataModel.updateTypingWithSelectedCandidateAt(selectedCandidateIndexPath, needCandidatesUpdate: false)
        candidatesUpdateQueue.cancelAllOperations()
        addCommonUpdateOperation(controller: controller)
    }
    
    func resetTyping() {
        self.controller.candidatesDataModel.resetTyping(needCandidatesUpdate: false)
        candidatesUpdateQueue.cancelAllOperations()
        addCommonUpdateOperation(controller: controller)
    }
    
    func addCommonUpdateOperation(controller: MyKeyboardViewController) {
        let commonUpdateOperation = CommonUpdateOperation(controller: controller)
        commonUpdateOperation.completionBlock = {
            if commonUpdateOperation.isCancelled {
                return
            }
            DispatchQueue.main.async(execute: {
                self.controller.insertCandidateAutomaticallyIfNecessary()
                self.controller.candidatesDataModel.commitUpdate()
                self.controller.updateCandidatesBanner()
            })
        }
        candidatesUpdateQueue.addOperation(commonUpdateOperation)
    }
    
    class CommonUpdateOperation: Operation {
        weak var controller: MyKeyboardViewController!
        
        init(controller: MyKeyboardViewController) {
            self.controller = controller
        }
        
        override func main() {
            autoreleasepool {
                if self.isCancelled {
                    return
                }
                
                self.controller.candidatesDataModel.prepareUpdateDataModelRaisedByTypingChange()
            }
        }
    }

    //*/
    
}


extension UIScrollView {
    func isKindOfMyCollectionViewFlowLayout() -> Bool {
        return ((self as! UICollectionView).collectionViewLayout.isKind(of: MyCollectionViewFlowLayout.self))
    }
}


