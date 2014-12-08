
import UIKit


let darkModeBannerColor = UIColor(red: 89, green: 92, blue: 95, alpha: 0.2)
let lightModeBannerColor = UIColor.whiteColor()
let darkModeBannerBorderColor = UIColor(white: 0.3, alpha: 1)
let lightModeBannerBorderColor = UIColor(white: 0.6, alpha: 1)

class CandidatesBanner: ExtraView {
    
    var collectionViewLayout: MyCollectionViewFlowLayout
    var collectionView: UICollectionView
    var moreCandidatesButton: UIButton
    var hasInitAppearance = false
    
    var delegate: protocol<UICollectionViewDataSource, UICollectionViewDelegate>! {
        didSet {
            collectionView.dataSource = delegate
            collectionView.delegate = delegate
        }
    }
    
    required init(globalColors: GlobalColors.Type?, darkMode: Bool, solidColorMode: Bool) {

        collectionViewLayout = MyCollectionViewFlowLayout()

        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: collectionViewLayout)
        collectionView.registerClass(CandidateCell.self, forCellWithReuseIdentifier: "Cell")
        
        moreCandidatesButton = UIButton.buttonWithType(.Custom) as UIButton
        moreCandidatesButton.addTarget(delegate, action: Selector("toggleCandidatesTable"), forControlEvents: .TouchUpInside)
        
        super.init(globalColors: globalColors, darkMode: darkMode, solidColorMode: solidColorMode)
        
        addSubview(collectionView)
        
        addSubview(moreCandidatesButton)
    
        moreCandidatesButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        var constraints = NSLayoutConstraint.constraintsWithVisualFormat("H:[button]-0-|", options: nil, metrics: nil, views: ["button": moreCandidatesButton])
        self.addConstraints(constraints)
        constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[button]-0-|", options: nil, metrics: nil, views: ["button": moreCandidatesButton])
        self.addConstraints(constraints)
        let constraint = NSLayoutConstraint(item: moreCandidatesButton, attribute: .Height, relatedBy: .Equal, toItem: moreCandidatesButton, attribute: .Width, multiplier: 0.8, constant: 0)
        self.addConstraint(constraint)
        
        collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
        constraints = NSLayoutConstraint.constraintsWithVisualFormat("H:[collectionView]-0-[button]", options: nil, metrics: nil, views: ["collectionView": collectionView, "button": moreCandidatesButton])
        self.addConstraints(constraints)
        constraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[collectionView]", options: nil, metrics: nil, views: ["collectionView": collectionView])
        self.addConstraints(constraints)
        constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[collectionView]-0-|", options: nil, metrics: nil, views: ["collectionView": collectionView])
        self.addConstraints(constraints)

        initAppearance()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func scrollToFirstCandidate() {
        collectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Left, animated: false)
    }
    
    func resetLayoutWithAllCellSize(sizes: [CGSize]) {
        collectionViewLayout.resetLayoutWithAllCellSize(sizes)
    }
    
    func updateCellAt(cellIndex: NSIndexPath, withCellSize size: CGSize) {
        collectionViewLayout.updateLayoutRaisedByCellAt(cellIndex, withCellSize: size)
        collectionView.reloadItemsAtIndexPaths([cellIndex])
    }
    
    func reloadData() {
        collectionView.reloadData()
        updateAppearance()
    }
    
    func setCollectionViewFrame(frame: CGRect) {
        collectionView.frame = frame
    }
    
    func initAppearance() {
        hasInitAppearance = true

        collectionView.backgroundColor = UIColor.clearColor()
        
        moreCandidatesButton.backgroundColor = UIColor.clearColor()
//        moreCandidatesButton.layer.borderColor = collectionView.layer.borderColor
        
        moreCandidatesButton.layer.shadowColor = UIColor.blackColor().CGColor
        moreCandidatesButton.layer.shadowOffset = CGSizeMake(-2.0, 0.0)
    }
    
    func updateAppearance() {
        if hasInitAppearance == false {
            initAppearance()
        }
        
        self.backgroundColor = candidatesBannerAppearanceIsDark ? darkModeBannerColor : UIColor.whiteColor()

        moreCandidatesButton.setImage(candidatesBannerAppearanceIsDark ? UIImage(named: "arrow-down-white") : UIImage(named: "arrow-down-black"), forState: .Normal)
        
        if collectionView.numberOfItemsInSection(0) <= 1 {
            self.layer.borderWidth = 0.5
            self.layer.borderColor = candidatesBannerAppearanceIsDark ? darkModeBannerBorderColor.CGColor : lightModeBannerBorderColor.CGColor
            moreCandidatesButton.hidden = true
            moreCandidatesButton.layer.shadowOpacity = 0.0
        } else {
            moreCandidatesButton.hidden = false
            addSeparatorLine()
            moreCandidatesButton.layer.shadowOpacity = 0.2
        }
    }
    
    func addSeparatorLine() {
        var leftBorder = CALayer(layer: moreCandidatesButton.layer)
        leftBorder.backgroundColor = candidatesBannerAppearanceIsDark ? darkModeBannerBorderColor.CGColor : lightModeBannerBorderColor.CGColor
        leftBorder.frame = CGRectMake(0, 0, 0.5, CGRectGetHeight(moreCandidatesButton.frame))
        moreCandidatesButton.layer.addSublayer(leftBorder)
    }
    
    func hideCollectionView() {
        collectionView.hidden = true
    }

    func unhideCollectionView() {
        collectionView.hidden = false
    }

    func changeArrowUp() {
        moreCandidatesButton.setImage(candidatesBannerAppearanceIsDark ? UIImage(named: "arrow-up-white") : UIImage(named: "arrow-up-black"), forState: .Normal)
    }

    func changeArrowDown() {
        moreCandidatesButton.setImage(candidatesBannerAppearanceIsDark ? UIImage(named: "arrow-down-white") : UIImage(named: "arrow-down-black"), forState: .Normal)
    }
    
}
