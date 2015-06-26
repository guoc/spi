
import UIKit

var showTypingCellInExtraLine = getShowTypingCellInExtraLineFromSettings()

func updateShowTypingCellInExtraLine() {
    showTypingCellInExtraLine = getShowTypingCellInExtraLineFromSettings()
}

func getShowTypingCellInExtraLineFromSettings() -> Bool {
    return NSUserDefaults.standardUserDefaults().boolForKey("kShowTypingCellInExtraLine")    // If not exist, false will be returned.
}

func getEnableGestureFromSettings() -> Bool {
    return NSUserDefaults.standardUserDefaults().boolForKey("kGesture")    // If not exist, false will be returned.
}

var cornerBracketEnabled = getCornerBracketEnabledFromSettings()

func updateCornerBracketEnabled() {
    cornerBracketEnabled = getCornerBracketEnabledFromSettings()
}

func getCornerBracketEnabledFromSettings() -> Bool {
    return NSUserDefaults.standardUserDefaults().boolForKey("kCornerBracket")    // If not exist, false will be returned.
}

var candidatesBannerAppearanceIsDark = false

let indexPathZero = NSIndexPath(forRow: 0, inSection: 0)
let indexPathFirst = NSIndexPath(forRow: 1, inSection: 0)

var startTime: NSDate?

class MyKeyboardViewController: KeyboardViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, IASKSettingsDelegate, ForwardingViewDelegate {

    let candidatesDataModel = CandidatesDataModel()

    var candidatesBanner: CandidatesBanner?
    
    var candidatesUpdateQueue: CandidatesUpdateQueue!
    
    var ignoreKeyPressOnce: Bool = false
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        Logger.sharedInstance.writeLogLine(filledString: "<<<<<<<<<\n")
        
        self.forwardingView.delegate = self
        self.candidatesUpdateQueue = CandidatesUpdateQueue(controller: self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("settingDidChange:"), name: "kAppSettingChanged", object: nil)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        Logger.sharedInstance.writeLogLine(filledString: ">>>>>>>>>\n")
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func insertCandidateAutomaticallyIfNecessary() {
        if let candidate = candidatesDataModel.getTypingCompleteCachedCandidate() {
            (self.textDocumentProxy as? UIKeyInput)!.insertText(candidate)
            candidatesDataModel.typingString.reset()
            candidatesDataModel.updateDataModelRaisedByTypingChange()
        }
    }
    
    func updateBannerHeight() {
        
        func changeBannerIfNecessary(#newHeight: CGFloat) {
            if metric("topBanner") != newHeight {
                changeBannerHeight(newHeight)
                candidatesBanner?.resetSubviewsWithInitAndSetDelegate()
            }
        }
        
        changeBannerIfNecessary(newHeight: (showTypingCellInExtraLine ? bannerHeightWhenShowTypingCellInExtraLineIsTrue : bannerHeightWhenShowTypingCellInExtraLineIsFalse))
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        if NSUserDefaults.standardUserDefaults().boolForKey("kLogging") {
            let memoryUsageReport = Logger.sharedInstance.getMemoryUsageReport()
            (self.textDocumentProxy as? UIKeyInput)!.insertText("MEMORY LOW")
            Logger.sharedInstance.writeLogLine(filledString: "!!!!!!!!!\n! \(memoryUsageReport)")
        }
    }
    
    override func keyPressed(key: Key) {
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
                
        if key.type == .Space {
            if candidatesDataModel.hasTyping() {
                if let firstCandidate = candidatesDataModel.textAt(indexPathFirst) {
                    candidatesUpdateQueue.selectCandidate(indexPathFirst)
                } else {
                    let typingStringAsCandidate = candidatesDataModel.getUserTypingString()
                    (self.textDocumentProxy as? UIKeyInput)!.insertText(typingStringAsCandidate)
                    candidatesUpdateQueue.selectCandidate(indexPathZero)
                }
            } else {
                // Insert Space
                (self.textDocumentProxy as? UIKeyInput)!.insertText(key.outputForCase(self.shiftState.uppercase()))
            }
            return
        } else if key.type == .Return {
            if candidatesDataModel.hasTyping() {
                let typingStringAsCandidate = candidatesDataModel.getUserTypingString()
                (self.textDocumentProxy as? UIKeyInput)!.insertText(typingStringAsCandidate)
                candidatesUpdateQueue.selectCandidate(indexPathZero)
            } else {
                // Insert Return
                (self.textDocumentProxy as? UIKeyInput)!.insertText(key.outputForCase(self.shiftState.uppercase()))
            }
        } else if key.type == .Character {    // Letters
            candidatesUpdateQueue.appendTyping(key.outputForCase(self.shiftState.uppercase()))
        } else {    // Special characters
            if candidatesDataModel.hasTyping() {
                candidatesUpdateQueue.appendTyping(key.outputForCase(self.shiftState.uppercase()))
            } else {
                (self.textDocumentProxy as? UIKeyInput)!.insertText(key.outputForCase(self.shiftState.uppercase()))
            }
        }
        /* */
    }
    
    override func keyPressedHelper(sender: KeyboardKey) {
        super.keyPressedHelper(sender)    // keyPressed is called in super.keyPressedHelper
        if candidatesDataModel.hasTyping() {
            autoPeriodState = .NoSpace
        }
    }
    
    var isDeletingTyping = false
    
    override func backspaceDown(sender: KeyboardKey) {
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
            (textDocumentProxy as? UIKeyInput)?.deleteBackward()
        }
        /* */
        
        // trigger for subsequent deletes
        self.backspaceDelayTimer = NSTimer.scheduledTimerWithTimeInterval(backspaceDelay - backspaceRepeat, target: self, selector: Selector("backspaceDelayCallback"), userInfo: nil, repeats: false)
    }
    
    override func backspaceUp(sender: KeyboardKey) {
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
                (textDocumentProxy as? UIKeyInput)?.deleteBackward()
            }
        }
        /* */
    }
    
    override func shiftDown(sender: KeyboardKey) {
        super.shiftDown(sender)
        
        Logger.sharedInstance.writeLogLine(filledString: "[SHIFT] <")
    }
    
    override func shiftUp(sender: KeyboardKey) {
        super.shiftUp(sender)
        
        Logger.sharedInstance.writeLogLine(filledString: "[SHIFT] >")
    }
    
    override func shiftDoubleTapped(sender: KeyboardKey) {
        super.shiftDoubleTapped(sender)
        
        Logger.sharedInstance.writeLogLine(filledString: "[SHIFT] <><")
    }
    
    override func modeChangeTapped(sender: KeyboardKey) {
        let tappedKeyText = sender.label.text ?? "[MODE] ???"
        
        super.modeChangeTapped(sender)

        Logger.sharedInstance.writeLogLine(filledString: "[\(tappedKeyText)] <>")
    }
    
    override func advanceTapped(sender: KeyboardKey) {
        super.advanceTapped(sender)
        
        Logger.sharedInstance.writeLogLine(filledString: "[NEXT IM]")
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        
        Logger.sharedInstance.writeLogLine(selectedCellIndex: indexPath.row, selectedCellText: (collectionView.cellForItemAtIndexPath(indexPath) as! CandidateCell).textLabel.text!)
        
        if indexPath == indexPathZero {
            if candidatesDataModel.hasTyping() {
                if candidatesDataModel.typingString.hasSelectedPartialCandidates() {
                    let displayedTypingStringAsCandidate = candidatesDataModel.textAt(indexPathZero)
                    (self.textDocumentProxy as? UIKeyInput)!.insertText(displayedTypingStringAsCandidate!)
                    candidatesUpdateQueue.selectCandidate(indexPathZero)
                } else {
                    let typingStringAsCandidate = candidatesDataModel.getUserTypingString()
                    (self.textDocumentProxy as? UIKeyInput)!.insertText(typingStringAsCandidate)
                    candidatesUpdateQueue.selectCandidate(indexPathZero)
                }
            }
        } else {
            let selectedCandidate = candidatesDataModel.textAt(indexPath)!
            candidatesUpdateQueue.selectCandidate(indexPath)
        }
    }
        
    func changeBannerHeight(height: CGFloat) {
        metrics["topBanner"] = Double(height)
        
        self.keyboardHeight = self.heightForOrientation(self.interfaceOrientation, withTopBanner: true)
    }
    
    override func createBanner() -> ExtraView? {
        
        candidatesBanner = CandidatesBanner(globalColors: self.dynamicType.globalColors, darkMode: false, solidColorMode: self.solidColorMode())
        candidatesBanner!.delegate = self
        
        return candidatesBanner
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return candidatesDataModel.numberOfTypingAndCandidates()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! CandidateCell
        cell.updateAppearance()
        if (indexPath == indexPathZero) {
            cell.textLabel.textAlignment = .Left
        } else {
            cell.textLabel.textAlignment = .Center
        }
        cell.textLabel.text = candidatesDataModel.textAt(indexPath)
//        cell.textLabel.sizeToFit()
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return getCellSizeAtIndex(indexPath, inDataModel: candidatesDataModel, andSetLayout: collectionViewLayout as! UICollectionViewFlowLayout)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        candidatesBanner!.setCollectionViewFrame(CGRect(x: 0, y: 0, width: self.view.bounds.width, height: candidateCellHeight))
    }
    
    func getCellSizeAtIndex(indexPath: NSIndexPath, inDataModel dataModel: CandidatesDataModel, andSetLayout layout: UICollectionViewFlowLayout) -> CGSize {
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
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {

        let collectionView = scrollView as! UICollectionView
        let visibleItems = collectionView.indexPathsForVisibleItems()
    
        if scrollView.isKindOfMyCollectionViewFlowLayout() == false {    // For candidates table scroll
            
            return
            
        } else {    // For candidates banner scroll
        
            var mostLeftCellIndexPathRow = visibleItems.reduce(Int.max) {
                min($0, $1.row)
            }
            
            var mostRightCellIndexPathRow = visibleItems.reduce(Int.min) {
                max($0, $1.row)
            }
            
            var mostLeftCellIndexPath = NSIndexPath(forItem: mostLeftCellIndexPathRow, inSection: 0)
            var mostRightCellIndexPath = NSIndexPath(forItem: mostRightCellIndexPathRow, inSection: 0)
            
            // Avoid wrong calculation when candidate cell is wider than the width of collectionView
            let collectionViewBoundsX = collectionView.bounds.origin.x
            if collectionView.layoutAttributesForItemAtIndexPath(mostRightCellIndexPath)!.frame.minX <= (collectionViewBoundsX > 0 ? collectionViewBoundsX : 0) {    // Expression "? :" for the case when collectionViewBoundsX < 0 because of inset
                if mostRightCellIndexPath.row + 1 < collectionView.numberOfItemsInSection(0) {
                    mostRightCellIndexPath = NSIndexPath(forItem: mostRightCellIndexPath.row + 1, inSection: 0)
                }
            }
            
            nextPageStartX = collectionView.layoutAttributesForItemAtIndexPath(mostRightCellIndexPath)!.frame.minX
            
            let maxXOfMostLeftCell = collectionView.layoutAttributesForItemAtIndexPath(mostLeftCellIndexPath)!.frame.maxX
            var indexPath: NSIndexPath! = mostLeftCellIndexPath
            while collectionView.layoutAttributesForItemAtIndexPath(indexPath)!.frame.minX + collectionView.bounds.width >= maxXOfMostLeftCell {
                if indexPath.row - 1 < 0 {
                    break
                } else {
                    indexPath = NSIndexPath(forRow: indexPath.row - 1, inSection: indexPath.section)
                }
            }
            
            if indexPath.row == mostLeftCellIndexPath.row {
                // Avoid wrong calculation when candidate cell is wider than the width of collectionView
                if indexPath.row - 1 < 0 {
                    indexPath = indexPathZero
                } else {
                    indexPath = NSIndexPath(forRow: indexPath.row - 1, inSection: indexPath.section)
                }
            } else {
                if indexPath.row - 1 < 0 {
                    indexPath = indexPathZero
                } else {
                    indexPath = NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)
                }
            }
            
            previousPageStartX = collectionView.layoutAttributesForItemAtIndexPath(indexPath)!.frame.minX
            
        }
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView.isKindOfMyCollectionViewFlowLayout() == false {    // For candidates table scroll
            
            return
            
        } else {    // For candidates banner scroll
            
            assert(previousPageStartX < nextPageStartX, "Calculate wrong pages start")
            if targetContentOffset.memory.x > nextPageStartX {
                targetContentOffset.memory.x = nextPageStartX
            }
            if targetContentOffset.memory.x < previousPageStartX {
                targetContentOffset.memory.x = previousPageStartX
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
    override func updateAppearances(appearanceIsDark: Bool) {
        candidatesBannerAppearanceIsDark = appearanceIsDark
        candidatesUpdateQueue.resetTyping()
        super.updateAppearances(appearanceIsDark)
        candidatesBanner?.updateAppearance()
    }
    
    var currentOrientation: UIInterfaceOrientation? = nil
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        super.willRotateToInterfaceOrientation(toInterfaceOrientation, duration: duration)
        if currentOrientation == nil || currentOrientation! != toInterfaceOrientation {
            switch(toInterfaceOrientation) {
            case .Unknown, .Portrait, .PortraitUpsideDown:
                candidatesBanner?.removeConstraints(candidatesBanner!.landscapeBannerWidthConstraints!)
                candidatesBanner?.addConstraints(candidatesBanner!.potraitBannerWidthConstraints!)
            case .LandscapeLeft, .LandscapeRight:
                candidatesBanner?.removeConstraints(candidatesBanner!.potraitBannerWidthConstraints!)
                candidatesBanner?.addConstraints(candidatesBanner!.landscapeBannerWidthConstraints!)
            }
        }
        currentOrientation = toInterfaceOrientation
    }
    
    var needDismissKeyboard = false
    func settingDidChange(notification: NSNotification) {
        needDismissKeyboard = true
        if (notification.object?.isEqual("kShowTypingCellInExtraLine") != nil) {
            updateShowTypingCellInExtraLine()
            self.updateBannerHeight()
        }
        if (notification.object?.isEqual("kCornerBracket") != nil) {
            updateCornerBracketEnabled()
        }
    }
    
    private func outputUserHistory() {
        let documentsFolder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        let historyDatabasePath = documentsFolder.stringByAppendingPathComponent("history.sqlite")
        
        let historyDatabase = FMDatabase(path: historyDatabasePath)
        
        if !historyDatabase.open() {
            println("Unable to open database")
            return
        }
        
        let candidatesDatabasePath = NSBundle.mainBundle().pathForResource("candidates", ofType: "sqlite")
        let candidatesDatabase = FMDatabase(path: candidatesDatabasePath)
        if !candidatesDatabase.open() {
            assertionFailure("Unable to open database")
        }
        
        var rows: [Row] = []
        
        if let rs = historyDatabase.executeQuery("select candidate, shuangpin, shengmu, length, frequency, candidate_type from history order by shengmu", withArgumentsInArray: nil) {
            while rs.next() {
                let row = rs.resultDictionary()
                if let rs = candidatesDatabase.executeQuery("select * from candidates where candidate == ?", withArgumentsInArray: [row["candidate"] as! String]) {
                    if !rs.next() {
                        rows.append(row)
                    }
                } else {
                    fatalError("select failed: \(candidatesDatabase.lastErrorMessage())")
                }
                
            }
        } else {
            println("select failed: \(historyDatabase.lastErrorMessage())")
        }
        
        let orderedRows: [Row] = rows.sorted { (lhs: Row, rhs: Row) -> Bool in
            return (lhs["frequency"] as! NSNumber).integerValue > (rhs["frequency"] as! NSNumber).integerValue
        }
        
        for row in orderedRows {
            let shuangpin = row["shuangpin"] as! String
            let shengmu = row["shengmu"] as! String
            let length = row["length"] as! Int
            let frequency = row["frequency"] as! Int
            let candidate = row["candidate"] as! String
            let candidateType = row["candidate_type"] as! Int
            (self.textDocumentProxy as? UIKeyInput)!.insertText("\(candidate),\(shuangpin),\(shengmu),\(length),\(frequency),\(candidateType);")
        }
        
        historyDatabase.close()
        candidatesDatabase.close()
    }

    private func run_command(commandStr: String) {
        switch commandStr {
        case "crash":
            func crash() {
                var a = 0
                a = a + 10
                let arr = [1,2,3]
                let b = arr[10]
            }
            crash()
        case "export":
            outputUserHistory()
        case "import":
            var imported = false
            let previousContext = (self.textDocumentProxy as? UITextDocumentProxy)?.documentContextBeforeInput
            if previousContext != nil {
                let historyLine = previousContext!
                let historyCandidates = split(historyLine) { $0 == ";" }
                for candidate in historyCandidates {
                    let candidateParts = split(candidate) { $0 == "," }
                    if candidateParts.count == 6 {
                        let candidateText = candidateParts[0]
                        let shuangpin = candidateParts[1]
                        let shengmu = candidateParts[2]
                        let length: Int? = candidateParts[3].toInt()
                        let frequency: Int? = candidateParts[4].toInt()
                        let candidateType: Int? = candidateParts[5].toInt()
                        if length != nil && frequency != nil && candidateType != nil {
                            candidatesDataModel.inputHistory.updateDatabase(candidateText: candidateText, shuangpin: shuangpin, shengmu: shengmu, length: NSNumber(long: length!), frequency: NSNumber(long: frequency!), candidateType: String(candidateType!))
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
                (self.textDocumentProxy as? UIKeyInput)!.insertText("导入成功 :]]")
            } else {
                (self.textDocumentProxy as? UIKeyInput)!.insertText("导入失败 :[[")
            }
        case "clean":
            candidatesDataModel.inputHistory.cleanAllCandidates()
        case "turnonlog":
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "kLogging")
        case "turnofflog":
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "kLogging")
        case "log":
            let logString = Logger.sharedInstance.getLogFileContent()
            (self.textDocumentProxy as? UIKeyInput)!.insertText(logString)
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
            let lastCharacter = typingBeforeToggleSettings[typingBeforeToggleSettings.endIndex.predecessor()]
            switch lastCharacter {
            case "+":
                if let documentContextAfterInput = (self.textDocumentProxy as! UITextDocumentProxy).documentContextAfterInput {
                    if typingBeforeToggleSettings != "" && documentContextAfterInput != "" {
                        let candidateTextLength = documentContextAfterInput.getReadingLength()
                        (self.textDocumentProxy as! UITextDocumentProxy).adjustTextPositionByCharacterOffset(candidateTextLength)
                        for _ in 0..<candidateTextLength {
                            (textDocumentProxy as? UIKeyInput)?.deleteBackward()
                        }
                        let initStr = typingBeforeToggleSettings.substringToIndex(typingBeforeToggleSettings.endIndex.predecessor())
                        candidatesDataModel.inputHistory.updateDatabase(candidateText: documentContextAfterInput, customCandidateQueryString: initStr)
                        candidatesUpdateQueue.resetTyping()
                        return
                    } else {
                        
                    }
                } else {
                    
                }
            case "!":
                let initStr = typingBeforeToggleSettings.substringToIndex(typingBeforeToggleSettings.endIndex.predecessor())
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
        self.presentViewController(aNavController, animated: true, completion: nil)
    }
    
    func settingsViewControllerDidEnd(sender: IASKAppSettingsViewController!) {
        if self.needDismissKeyboard == true {
            self.dismissKeyboard()    // Dismiss keyboard to reload candidates banner appearance.
        }
        self.needDismissKeyboard = false
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
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
        var layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Vertical
        candidatesTable = UICollectionView(frame: CGRect(x: view.frame.origin.x, y: view.frame.origin.y + getBannerHeight(), width: view.frame.width, height: view.frame.height - getBannerHeight()), collectionViewLayout: layout)
        candidatesTable.backgroundColor = candidatesBannerAppearanceIsDark ? UIColor.darkGrayColor() : UIColor.whiteColor()
        candidatesTable.registerClass(CandidateCell.self, forCellWithReuseIdentifier: "Cell")
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
    
    private func commandForKey(key: Key) -> (() -> ())? {
        if let character = key.lowercaseOutput {
            switch(character) {
            case "d":
                return { () in return
                    self.candidatesDataModel.inputHistory.deleteRecentCreatedCandidate()
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
                if beginKey.type == .Space {
                    if let endKeyView = endView as? KeyboardKey {
                        if let endKey = self.layout?.keyForView(endKeyView) {
                            if endKey.type != .Space {
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        Logger.sharedInstance.writeLogLine(filledString: "--------- VDA\n")
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        Logger.sharedInstance.writeLogLine(filledString: "--------- VDDA\n")
    }
    
}

class CandidatesUpdateQueue {
    
    lazy var candidatesUpdateQueue: NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "Candidates update queue"
        queue.maxConcurrentOperationCount = 1
        return queue
        }()
    let controller: MyKeyboardViewController
    
    init(controller: MyKeyboardViewController) {
        self.controller = controller
    }
    
    func appendTyping(text: String) {
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
    
    func selectCandidate(selectedCandidateIndexPath: NSIndexPath) {
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
    
    func addCommonUpdateOperation(#controller: MyKeyboardViewController) {
        let commonUpdateOperation = CommonUpdateOperation(controller: controller)
        commonUpdateOperation.completionBlock = {
            if commonUpdateOperation.cancelled {
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.controller.insertCandidateAutomaticallyIfNecessary()
                self.controller.candidatesDataModel.commitUpdate()
                self.controller.updateCandidatesBanner()
            })
        }
        candidatesUpdateQueue.addOperation(commonUpdateOperation)
    }
    
    class CommonUpdateOperation: NSOperation {
        let controller: MyKeyboardViewController
        
        init(controller: MyKeyboardViewController) {
            self.controller = controller
        }
        
        override func main() {
            autoreleasepool {
                if self.cancelled {
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
        return ((self as! UICollectionView).collectionViewLayout.isKindOfClass(MyCollectionViewFlowLayout))
    }
}


