//
//  CandidateCell.swift
//  TastyImitationKeyboard
//
//  Created by GuoChen on 11/11/2014.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import UIKit

var candidateTextFont = UIFont(descriptor: UIFontDescriptor.preferredFontDescriptorWithTextStyle(UIFontTextStyleBody), size: 20)

// Somewhen this should be cleared
var textWidthCache = [Int: CGFloat]()

class CandidateCell: UICollectionViewCell {
    
    let textLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        selectedBackgroundView = UIView(frame: frame)
        selectedBackgroundView.autoresizingMask = .FlexibleWidth
        selectedBackgroundView.backgroundColor = UIColor.lightGrayColor()

        textLabel = UILabel()
        textLabel.font = candidateTextFont
        textLabel.textAlignment = .Center
        textLabel.baselineAdjustment = .AlignCenters
        textLabel.lineBreakMode = .ByTruncatingTail
        contentView.addSubview(textLabel)
        
        textLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        let constraints = NSLayoutConstraint.constraintsWithVisualFormat("|-8-[textLabel]-8-|", options: nil, metrics: nil, views: ["textLabel": textLabel])
        self.contentView.addConstraints(constraints)
        let constraint = NSLayoutConstraint(item: textLabel, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1, constant: 0)
        self.contentView.addConstraint(constraint)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func updateAppearance() {
        if candidatesBannerAppearanceIsDark == true {
            textLabel.textColor = UIColor.whiteColor()
        } else {
            textLabel.textColor = UIColor.darkTextColor()        }
    }
    
    class func getCellSizeByText(text: String) -> CGSize {
        let utf32Length = text.lengthOfBytesUsingEncoding(NSUTF32StringEncoding)
        let acsiiLength = text.lengthOfBytesUsingEncoding(NSASCIIStringEncoding)
        let textIsAlphabetic: Bool = (utf32Length / 4 == acsiiLength)
        let textLength = utf32Length / 4
        var returnWidth: CGFloat!
        let cachedWidth = textWidthCache[textLength]
        if textIsAlphabetic || cachedWidth == nil {
            let maxTypingCandidateCellWidth = CGFloat.infinity
            let textWidth = (text as NSString).boundingRectWithSize(CGSize(width: maxTypingCandidateCellWidth, height: metric("topBanner")), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: candidateTextFont], context: nil).width + 20
            if textWidth > maxTypingCandidateCellWidth {
                returnWidth = maxTypingCandidateCellWidth
            } else if textWidth < defaultCandidateCellWidth {
                returnWidth = defaultCandidateCellWidth
            } else {
                returnWidth = textWidth
            }
            if textIsAlphabetic == false {
                textWidthCache[textLength] = returnWidth
            }
        } else {
            returnWidth = cachedWidth
        }
        return CGSize(width: returnWidth, height: metric("topBanner"))
    }
}
