//
//  CandidateCell.swift
//  TastyImitationKeyboard
//
//  Created by GuoChen on 11/11/2014.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import UIKit

var candidateTextFont = UIFont(descriptor: UIFontDescriptor.preferredFontDescriptorWithTextStyle(UIFontTextStyleBody), size: 20)

let oneChineseGlyphWidth = ("镜" as NSString).boundingRectWithSize(CGSize(width: CGFloat.infinity, height: metric("topBanner")), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: candidateTextFont], context: nil).width

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
    
    class func getCellSizeByText(text: String, needAccuracy: Bool) -> CGSize {
        var textWidth: CGFloat = 0
        if needAccuracy {
            textWidth = (text as NSString).boundingRectWithSize(CGSize(width: CGFloat.infinity, height: metric("topBanner")), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: candidateTextFont], context: nil).width + 20
        } else {
            textWidth = oneChineseGlyphWidth * CGFloat(text.getReadingLength()) + 20
        }
        var returnWidth: CGFloat = 0
        if textWidth < defaultCandidateCellWidth {
            returnWidth = defaultCandidateCellWidth
        } else {
            returnWidth = textWidth
        }
        return CGSize(width: returnWidth, height: metric("topBanner"))
    }
}
