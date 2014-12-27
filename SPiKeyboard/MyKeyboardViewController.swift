
import UIKit

var candidatesBannerAppearanceIsDark = false

let indexPathZero = NSIndexPath(forRow: 0, inSection: 0)
let indexPathFirst = NSIndexPath(forRow: 1, inSection: 0)

var startTime: NSDate?

class MyKeyboardViewController: KeyboardViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, IASKSettingsDelegate {

    let candidatesDataModel = CandidatesDataModel()

    var candidatesBanner: CandidatesBanner?
    
    let candidatesUpdateQueue: CandidatesUpdateQueue!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.candidatesUpdateQueue = CandidatesUpdateQueue(controller: self)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func insertCandidateAutomaticallyIfNecessary() {
        if let candidate = candidatesDataModel.getTypingCompleteCachedCandidate() {
            (self.textDocumentProxy as? UIKeyInput)!.insertText(candidate)
            candidatesDataModel.typingString.reset()
            candidatesDataModel.updateDataModelRaisedByTypingChange()
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
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        
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
    
    override func createBanner() -> ExtraView? {
//        candidatesDataModel.generateDatabaseFromTxtSource()
        
        candidatesBanner = CandidatesBanner(globalColors: self.dynamicType.globalColors, darkMode: false, solidColorMode: self.solidColorMode())
        candidatesBanner!.delegate = self
        
        return candidatesBanner
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return candidatesDataModel.numberOfTypingAndCandidates()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as CandidateCell
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
        return getCellSizeAtIndex(indexPath, inDataModel: candidatesDataModel, andSetLayout: collectionViewLayout as UICollectionViewFlowLayout)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        candidatesBanner!.setCollectionViewFrame(CGRect(x: 0, y: 0, width: self.view.bounds.width, height: metric("topBanner")))
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

        let collectionView = scrollView as UICollectionView
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
    
    @IBAction override func toggleSettings() {
        let hideInputHistory = (candidatesDataModel.typingString.userTypingString != "history")
        candidatesUpdateQueue.resetTyping()
        let keyboardSettingsViewController = IASKAppSettingsViewController()
        keyboardSettingsViewController.delegate = self
        let aNavController = UINavigationController(rootViewController: keyboardSettingsViewController)
        keyboardSettingsViewController.showCreditsFooter = false
        keyboardSettingsViewController.showDoneButton = true
        keyboardSettingsViewController.hiddenKeys = hideInputHistory ? NSSet(object: "kInputHistory") : nil
        self.presentViewController(aNavController, animated: true, completion: nil)
    }
    
    func settingsViewControllerDidEnd(sender: IASKAppSettingsViewController!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        ShuangpinScheme.reloadScheme()
    }
    
    override func shouldAutoCapitalize() -> Bool {
        return false
    }
    
    var isShowingCandidatesTable = false
    @IBAction func toggleCandidatesTable() {
        if isShowingCandidatesTable == false {
            isShowingCandidatesTable = true
            showCandidatesTable()
        } else {
            isShowingCandidatesTable = false
            exitCandidatesTable()
        }
    }
    
    var candidatesTable: UICollectionView!
    func showCandidatesTable() {
        isShowingCandidatesTable = true
        candidatesBanner!.hideCollectionView()
        candidatesBanner!.changeArrowUp()
        var layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Vertical
        candidatesTable = UICollectionView(frame: CGRect(x: view.frame.origin.x, y: view.frame.origin.y + metric("topBanner"), width: view.frame.width, height: view.frame.height - metric("topBanner")), collectionViewLayout: layout)
        candidatesTable.backgroundColor = candidatesBannerAppearanceIsDark ? UIColor.darkGrayColor() : UIColor.whiteColor()
        candidatesTable.registerClass(CandidateCell.self, forCellWithReuseIdentifier: "Cell")
        candidatesTable.delegate = self
        candidatesTable.dataSource = self
        self.view.addSubview(candidatesTable)
    }
    
    func exitCandidatesTable() {
        isShowingCandidatesTable = false
        candidatesBanner!.scrollToFirstCandidate()
        candidatesBanner!.unhideCollectionView()
        candidatesBanner!.changeArrowDown()
        candidatesTable.removeFromSuperview()
    }
    
    func exitCandidatesTableIfNecessary() {
        if isShowingCandidatesTable == false {
            return
        }
        exitCandidatesTable()
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
        return ((self as UICollectionView).collectionViewLayout.isKindOfClass(MyCollectionViewFlowLayout))
    }
}


