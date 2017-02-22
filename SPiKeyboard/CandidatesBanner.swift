
import UIKit

let darkModeBannerColor = UIColor(red: 89, green: 92, blue: 95, alpha: 0.2)
let lightModeBannerColor = UIColor.white
let darkModeBannerBorderColor = UIColor(white: 0.3, alpha: 1)
let lightModeBannerBorderColor = UIColor(white: 0.6, alpha: 1)

let extraLineTypingTextFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
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

    var potraitBannerWidthConstraints: [NSLayoutConstraint]? = nil
    var landscapeBannerWidthConstraints: [NSLayoutConstraint]? = nil
    
    weak var delegate: (UICollectionViewDataSource & UICollectionViewDelegate)! {
        didSet {
            collectionView.dataSource = delegate
            collectionView.delegate = delegate
            configureSubviews()
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

        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewLayout)
        collectionView.register(CandidateCell.self, forCellWithReuseIdentifier: "Cell")
        
        moreCandidatesButton = UIButton(type: .custom)
        moreCandidatesButton.addTarget(delegate, action: #selector(MyKeyboardViewController.toggleCandidatesTableOrDismissKeyboard), for: .touchUpInside)
        
        // Above part should be same as func initSubviews()
        
        super.init(globalColors: globalColors, darkMode: darkMode, solidColorMode: solidColorMode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func resetSubviewsWithInitAndSetDelegate() {
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
        initSubviews()
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
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewLayout)
        collectionView.register(CandidateCell.self, forCellWithReuseIdentifier: "Cell")
        
        moreCandidatesButton = UIButton(type: .custom)
        moreCandidatesButton.addTarget(delegate, action: #selector(MyKeyboardViewController.toggleCandidatesTableOrDismissKeyboard), for: .touchUpInside)
    }
    
    func configureSubviews() {
        
        addSubview(collectionView)
        
        addSubview(moreCandidatesButton)

        self.translatesAutoresizingMaskIntoConstraints = false
        moreCandidatesButton.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints: [NSLayoutConstraint]
        
        self.removeConstraints(self.constraints)
        let actualScreenWidth = (UIScreen.main.nativeBounds.size.width / UIScreen.main.nativeScale)
        let actualScreenHeight = (UIScreen.main.nativeBounds.size.height / UIScreen.main.nativeScale)
        if potraitBannerWidthConstraints == nil {
            potraitBannerWidthConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[banner(==\(actualScreenWidth)@1000)]", options: [], metrics: nil, views: ["banner": self])
        }
        if landscapeBannerWidthConstraints == nil {
            landscapeBannerWidthConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[banner(==\(actualScreenHeight)@1000)]", options: [], metrics: nil, views: ["banner": self])
        }
        switch((self.delegate as! MyKeyboardViewController).interfaceOrientation) {    // FIXME delegate should not be casted.
        case .unknown, .portrait, .portraitUpsideDown:
            self.addConstraints(potraitBannerWidthConstraints!)
        case .landscapeLeft, .landscapeRight:
            self.addConstraints(landscapeBannerWidthConstraints!)
        }
        let bannerHeight = getBannerHeight()
        constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[banner(==\(bannerHeight)@1000)]", options: [], metrics: nil, views: ["banner": self])
        self.addConstraints(constraints)
        
        constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[button]-0-|", options: [], metrics: nil, views: ["button": moreCandidatesButton])
        self.addConstraints(constraints)
        if showTypingCellInExtraLine == true {
            constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[button]-0-|", options: [], metrics: nil, views: ["button": moreCandidatesButton])
        } else {
            constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[button]-0-|", options: [], metrics: nil, views: ["button": moreCandidatesButton])
        }
        self.addConstraints(constraints)
        let constraint = NSLayoutConstraint(item: moreCandidatesButton, attribute: .height, relatedBy: .equal, toItem: moreCandidatesButton, attribute: .width, multiplier: 0.8, constant: 0)
        self.addConstraint(constraint)
        
        constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[collectionView]", options: [], metrics: nil, views: ["collectionView": collectionView])
        self.addConstraints(constraints)
        let candidateCellHeight = getCandidateCellHeight()
        if showTypingCellInExtraLine == true {
            constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[collectionView(==\(candidateCellHeight)@1000)]-0-|", options: [], metrics: nil, views: ["collectionView": collectionView])
        } else {
            constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[collectionView]-0-|", options: [], metrics: nil, views: ["collectionView": collectionView])
        }
        self.addConstraints(constraints)
        
        constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[collectionView]-0-[button]", options: [], metrics: nil, views: ["collectionView": collectionView, "button": moreCandidatesButton])
        self.addConstraints(constraints)
        
        if showTypingCellInExtraLine == true {
            if let typingLabel = typingLabel {
                
                addSubview(typingLabel)
                
                typingLabel.translatesAutoresizingMaskIntoConstraints = false
                
                constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[typingView]-0-|", options: [], metrics: nil, views: ["typingView": typingLabel])
                self.addConstraints(constraints)
                constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[typingView]", options: [], metrics: nil, views: ["typingView": typingLabel])
                self.addConstraints(constraints)
                
                constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[typingView]-0-[button]", options: [], metrics: nil, views: ["typingView": typingLabel, "button": moreCandidatesButton])
                self.addConstraints(constraints)
                constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[typingView]-0-[collectionView]", options: [], metrics: nil, views: ["typingView": typingLabel, "collectionView": collectionView])
                self.addConstraints(constraints)
            }
        }

        initAppearance()
    }
    
    func scrollToFirstCandidate() {
        collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: false)
    }
    
    func resetLayoutWithAllCellSize(_ sizes: [CGSize]) {
        collectionViewLayout.resetLayoutWithAllCellSize(sizes)
    }
    
    func updateCellAt(_ cellIndex: IndexPath, withCellSize size: CGSize) {
        collectionViewLayout.updateLayoutRaisedByCellAt(cellIndex, withCellSize: size)
        collectionView.reloadItems(at: [cellIndex])
    }
    
    func reloadData() {
        if let typingLabel = typingLabel {
            typingLabel.text = (delegate as! MyKeyboardViewController).candidatesDataModel.textAt(indexPathZero)    // FIXME
        }
        collectionView.reloadData()
    }
    
    func setCollectionViewFrame(_ frame: CGRect) {
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
            typingLabel.backgroundColor = UIColor.clear
        }

        collectionView.backgroundColor = UIColor.clear
        
        moreCandidatesButton.backgroundColor = UIColor.clear
//        moreCandidatesButton.layer.borderColor = collectionView.layer.borderColor
        
        moreCandidatesButton.layer.shadowColor = UIColor.black.cgColor
        moreCandidatesButton.layer.shadowOffset = CGSize(width: -2.0, height: 0.0)
        
        if needUpdateAppearance == true {
            updateAppearance()
        }
    }
    
    override func updateAppearance() {
        if hasInitAppearance == false {
            initAppearance()
        }
        
        updateSeparatorBars()
        
        typingLabel?.updateAppearance()
        
        self.backgroundColor = candidatesBannerAppearanceIsDark ? darkModeBannerColor : UIColor.white

        moreCandidatesButton.setImage(candidatesBannerAppearanceIsDark ? UIImage(named: "arrow-down-white") : UIImage(named: "arrow-down-black"), for: UIControlState())
        
        self.layer.borderWidth = 0.5
        self.layer.borderColor = candidatesBannerAppearanceIsDark ? darkModeBannerBorderColor.cgColor : lightModeBannerBorderColor.cgColor
        
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
            separatorVerticalBar!.backgroundColor = candidatesBannerAppearanceIsDark ? darkModeBannerBorderColor.cgColor : lightModeBannerBorderColor.cgColor
            separatorVerticalBar!.frame = CGRect(x: 0, y: 0, width: 0.5, height: moreCandidatesButton.frame.height)
            if let separatorVerticalBar = separatorVerticalBar {
                moreCandidatesButton.layer.addSublayer(separatorVerticalBar)
            }
        }
        
        if separatorHorizontalBar == nil {
            if showTypingCellInExtraLine == true {
                if let typingLabel = typingLabel {
                    if separatorHorizontalBar != nil {
                        separatorHorizontalBar!.removeFromSuperlayer()
                    }
                    separatorHorizontalBar = CALayer(layer: self.layer)
                    separatorHorizontalBar!.backgroundColor = candidatesBannerAppearanceIsDark ? darkModeBannerBorderColor.cgColor : lightModeBannerBorderColor.cgColor
                    separatorHorizontalBar!.frame = CGRect(x: 0, y: typingLabel.frame.height, width: (UIScreen.main.nativeBounds.size.height / UIScreen.main.nativeScale), height: 0.5)
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
        typingLabel?.isHidden = true
        collectionView.isHidden = true
    }

    func unhideTypingAndCandidatesView() {
        typingLabel?.isHidden = false
        collectionView.isHidden = false
    }

    func changeArrowUp() {
        moreCandidatesButton.setImage(candidatesBannerAppearanceIsDark ? UIImage(named: "arrow-up-white") : UIImage(named: "arrow-up-black"), for: UIControlState())
    }

    func changeArrowDown() {
        moreCandidatesButton.setImage(candidatesBannerAppearanceIsDark ? UIImage(named: "arrow-down-white") : UIImage(named: "arrow-down-black"), for: UIControlState())
    }
    
}
