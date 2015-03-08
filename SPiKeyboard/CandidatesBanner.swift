
import UIKit

let darkModeBannerColor = UIColor(red: 89, green: 92, blue: 95, alpha: 0.2)
let lightModeBannerColor = UIColor.whiteColor()
let darkModeBannerBorderColor = UIColor(white: 0.3, alpha: 1)
let lightModeBannerBorderColor = UIColor(white: 0.6, alpha: 1)

let extraLineTypingTextFont = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
let typingAndCandidatesViewHeightWhenShowTypingCellInExtraLineIsTrue = 28 as CGFloat
let bannerHeightWhenShowTypingCellInExtraLineIsTrue = 50 as CGFloat

let typingAndCandidatesViewHeightWhenShowTypingCellInExtraLineIsFalse = 35 as CGFloat
let bannerHeightWhenShowTypingCellInExtraLineIsFalse = 35 as CGFloat

let candidatesTableCellHeight = 35 as CGFloat

func getBannerHeight() -> CGFloat {
    return showTypingCellInExtraLine ? bannerHeightWhenShowTypingCellInExtraLineIsTrue : bannerHeightWhenShowTypingCellInExtraLineIsFalse
}

class CandidatesBanner: ExtraView {
    
    var typingLabel: TypingLabel?
    var collectionViewLayout: MyCollectionViewFlowLayout
    var collectionView: UICollectionView
    var moreCandidatesButton: UIButton
    var hasInitAppearance = false
    
    weak var delegate: protocol<UICollectionViewDataSource, UICollectionViewDelegate>! {
        didSet {
            collectionView.dataSource = delegate
            collectionView.delegate = delegate
        }
    }
    
    required init(globalColors: GlobalColors.Type?, darkMode: Bool, solidColorMode: Bool) {

        // Below part should be same as func initSubviews()
        
        if showTypingCellInExtraLine == true {
            typingLabel = TypingLabel()
        } else {
            typingLabel = nil
        }
        
        collectionViewLayout = MyCollectionViewFlowLayout()

        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: collectionViewLayout)
        collectionView.registerClass(CandidateCell.self, forCellWithReuseIdentifier: "Cell")
        
        moreCandidatesButton = UIButton.buttonWithType(.Custom) as UIButton
        moreCandidatesButton.addTarget(delegate, action: Selector("toggleCandidatesTableOrDismissKeyboard"), forControlEvents: .TouchUpInside)
        
        // Above part should be same as func initSubviews()
        
        super.init(globalColors: globalColors, darkMode: darkMode, solidColorMode: solidColorMode)
        
        configureSubviews()
        
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func resetSubviewsWithInitAndSetDelegate() {
        self.subviews.map({$0.removeFromSuperview()})
        initSubviews()
        configureSubviews()
        // Call delegate's didSet()
        let delegate = self.delegate
        self.delegate = delegate
    }
    
    func initSubviews() {
        if showTypingCellInExtraLine == true {
            typingLabel = TypingLabel()
        } else {
            typingLabel = nil
        }
        
        collectionViewLayout = MyCollectionViewFlowLayout()
        
        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: collectionViewLayout)
        collectionView.registerClass(CandidateCell.self, forCellWithReuseIdentifier: "Cell")
        
        moreCandidatesButton = UIButton.buttonWithType(.Custom) as UIButton
        moreCandidatesButton.addTarget(delegate, action: Selector("toggleCandidatesTable"), forControlEvents: .TouchUpInside)
    }
    
    func configureSubviews() {
        
        addSubview(collectionView)
        
        addSubview(moreCandidatesButton)

        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        moreCandidatesButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        var constraints: [AnyObject]
        
        self.removeConstraints(self.constraints())
        let actualScreenWidth = (UIScreen.mainScreen().nativeBounds.size.width / UIScreen.mainScreen().nativeScale)
        constraints = NSLayoutConstraint.constraintsWithVisualFormat("H:[banner(==\(actualScreenWidth)@1000)]", options: nil, metrics: nil, views: ["banner": self])
        self.addConstraints(constraints)
        let bannerHeight = getBannerHeight()
        constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[banner(==\(bannerHeight)@1000)]", options: nil, metrics: nil, views: ["banner": self])
        self.addConstraints(constraints)
        
        constraints = NSLayoutConstraint.constraintsWithVisualFormat("H:[button]-0-|", options: nil, metrics: nil, views: ["button": moreCandidatesButton])
        self.addConstraints(constraints)
        if showTypingCellInExtraLine == true {
            constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[button]-0-|", options: nil, metrics: nil, views: ["button": moreCandidatesButton])
        } else {
            constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[button]-0-|", options: nil, metrics: nil, views: ["button": moreCandidatesButton])
        }
        self.addConstraints(constraints)
        let constraint = NSLayoutConstraint(item: moreCandidatesButton, attribute: .Height, relatedBy: .Equal, toItem: moreCandidatesButton, attribute: .Width, multiplier: 0.8, constant: 0)
        self.addConstraint(constraint)
        
        constraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[collectionView]", options: nil, metrics: nil, views: ["collectionView": collectionView])
        self.addConstraints(constraints)
        let candidateCellHeight = getCandidateCellHeight()
        if showTypingCellInExtraLine == true {
            constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[collectionView(==\(candidateCellHeight)@1000)]-0-|", options: nil, metrics: nil, views: ["collectionView": collectionView])
        } else {
            constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[collectionView]-0-|", options: nil, metrics: nil, views: ["collectionView": collectionView])
        }
        self.addConstraints(constraints)
        
        constraints = NSLayoutConstraint.constraintsWithVisualFormat("H:[collectionView]-0-[button]", options: nil, metrics: nil, views: ["collectionView": collectionView, "button": moreCandidatesButton])
        self.addConstraints(constraints)
        
        if showTypingCellInExtraLine == true {
            if let typingLabel = typingLabel {
                
                addSubview(typingLabel)
                
                typingLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
                
                constraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[typingView]-0-|", options: nil, metrics: nil, views: ["typingView": typingLabel])
                self.addConstraints(constraints)
                constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[typingView]", options: nil, metrics: nil, views: ["typingView": typingLabel])
                self.addConstraints(constraints)
                
                constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[typingView]-0-[button]", options: nil, metrics: nil, views: ["typingView": typingLabel, "button": moreCandidatesButton])
                self.addConstraints(constraints)
                constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[typingView]-0-[collectionView]", options: nil, metrics: nil, views: ["typingView": typingLabel, "collectionView": collectionView])
                self.addConstraints(constraints)
            }
        }

        initAppearance()
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
        if let typingLabel = typingLabel {
            typingLabel.text = (delegate as MyKeyboardViewController).candidatesDataModel.textAt(indexPathZero)    // FIXME
        }
        collectionView.reloadData()
    }
    
    func setCollectionViewFrame(frame: CGRect) {
        collectionView.frame = frame
    }
    
    func initAppearance() {
        var needUpdateAppearance = false
        if hasInitAppearance == false {
            needUpdateAppearance = true
        }
        
        hasInitAppearance = true
        
        if let typingLabel = typingLabel {
            typingLabel.font = extraLineTypingTextFont
            typingLabel.backgroundColor = UIColor.clearColor()
        }

        collectionView.backgroundColor = UIColor.clearColor()
        
        moreCandidatesButton.backgroundColor = UIColor.clearColor()
//        moreCandidatesButton.layer.borderColor = collectionView.layer.borderColor
        
        moreCandidatesButton.layer.shadowColor = UIColor.blackColor().CGColor
        moreCandidatesButton.layer.shadowOffset = CGSizeMake(-2.0, 0.0)
        
        if needUpdateAppearance == true {
            updateAppearance()
        }
    }
    
    func updateAppearance() {
        if hasInitAppearance == false {
            initAppearance()
        }
        
        updateSeparatorBars()
        
        typingLabel?.updateAppearance()
        
        self.backgroundColor = candidatesBannerAppearanceIsDark ? darkModeBannerColor : UIColor.whiteColor()

        moreCandidatesButton.setImage(candidatesBannerAppearanceIsDark ? UIImage(named: "arrow-down-white") : UIImage(named: "arrow-down-black"), forState: .Normal)
        
        self.layer.borderWidth = 0.5
        self.layer.borderColor = candidatesBannerAppearanceIsDark ? darkModeBannerBorderColor.CGColor : lightModeBannerBorderColor.CGColor
        
        moreCandidatesButton.layer.shadowOpacity = 0.2        
    }
    
    var separatorHorizontalBar: CALayer?
    var separatorVerticalBar: CALayer?

    func updateSeparatorBars() {
        removeSeparatorBars()
        addSeparatorBars()
    }
    
    func addSeparatorBars() {
        if separatorVerticalBar == nil {
            separatorVerticalBar = CALayer(layer: moreCandidatesButton.layer)
            separatorVerticalBar!.backgroundColor = candidatesBannerAppearanceIsDark ? darkModeBannerBorderColor.CGColor : lightModeBannerBorderColor.CGColor
            separatorVerticalBar!.frame = CGRectMake(0, 0, 0.5, CGRectGetHeight(moreCandidatesButton.frame))
            moreCandidatesButton.layer.addSublayer(separatorVerticalBar)
        }
        
        if separatorHorizontalBar == nil {
            if showTypingCellInExtraLine == true {
                if let typingLabel = typingLabel {
                    if separatorHorizontalBar != nil {
                        separatorHorizontalBar!.removeFromSuperlayer()
                    }
                    separatorHorizontalBar = CALayer(layer: self.layer)
                    separatorHorizontalBar!.backgroundColor = candidatesBannerAppearanceIsDark ? darkModeBannerBorderColor.CGColor : lightModeBannerBorderColor.CGColor
                    separatorHorizontalBar!.frame = CGRectMake(0, CGRectGetHeight(typingLabel.frame), CGRectGetWidth(typingLabel.frame), 0.5)
                    self.layer.addSublayer(separatorHorizontalBar!)
                }
            }
        }
    }
    
    func removeSeparatorBars() {
        if separatorVerticalBar != nil {
            separatorVerticalBar!.removeFromSuperlayer()
            separatorVerticalBar = nil
        }
        if separatorHorizontalBar != nil {
            separatorHorizontalBar!.removeFromSuperlayer()
            separatorHorizontalBar = nil
        }
    }
    
    func hideTypingAndCandidatesView() {
        typingLabel?.hidden = true
        collectionView.hidden = true
    }

    func unhideTypingAndCandidatesView() {
        typingLabel?.hidden = false
        collectionView.hidden = false
    }

    func changeArrowUp() {
        moreCandidatesButton.setImage(candidatesBannerAppearanceIsDark ? UIImage(named: "arrow-up-white") : UIImage(named: "arrow-up-black"), forState: .Normal)
    }

    func changeArrowDown() {
        moreCandidatesButton.setImage(candidatesBannerAppearanceIsDark ? UIImage(named: "arrow-down-white") : UIImage(named: "arrow-down-black"), forState: .Normal)
    }
    
}
