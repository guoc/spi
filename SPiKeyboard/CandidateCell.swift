
import UIKit

func getCandidateCellHeight() -> CGFloat {
    return showTypingCellInExtraLine ? typingAndCandidatesViewHeightWhenShowTypingCellInExtraLineIsTrue : typingAndCandidatesViewHeightWhenShowTypingCellInExtraLineIsFalse
}

var candidateTextFont = UIFont(descriptor: UIFontDescriptor.preferredFontDescriptorWithTextStyle(UIFontTextStyleBody), size: 20)

let oneChineseGlyphWidth = ("镜" as NSString).boundingRectWithSize(CGSize(width: CGFloat.infinity, height: candidatesTableCellHeight), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: candidateTextFont], context: nil).width

class CandidateCell: UICollectionViewCell {
    
    var textLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        selectedBackgroundView = UIView(frame: frame)
        selectedBackgroundView?.autoresizingMask = .FlexibleWidth
        selectedBackgroundView?.backgroundColor = UIColor.lightGrayColor()

        textLabel = UILabel()
        textLabel.font = candidateTextFont
        textLabel.textAlignment = .Center
        textLabel.baselineAdjustment = .AlignCenters
        textLabel.lineBreakMode = .ByTruncatingTail
        contentView.addSubview(textLabel)
        
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        let constraints = NSLayoutConstraint.constraintsWithVisualFormat("|-8-[textLabel]-8-|", options: [], metrics: nil, views: ["textLabel": textLabel])
        self.contentView.addConstraints(constraints)
        let constraint = NSLayoutConstraint(item: textLabel, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1, constant: 0)
        self.contentView.addConstraint(constraint)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func updateAppearance() {
        if candidatesBannerAppearanceIsDark == true {
            textLabel.textColor = UIColor.whiteColor()
        } else {
            textLabel.textColor = UIColor.darkTextColor()
        }
    }
    
    class func getCellSizeByText(text: String, needAccuracy: Bool) -> CGSize {
        
        func accurateWidth() -> CGFloat {
            return (text as NSString).boundingRectWithSize(CGSize(width: CGFloat.infinity, height: getCandidateCellHeight()), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: candidateTextFont], context: nil).width + 20
        }
        
        var textWidth: CGFloat = 0
        if needAccuracy {
            textWidth = accurateWidth()
        } else {
            let length = text.getReadingLength()
            let utf8Length = text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
            if utf8Length == length * 3 {
                textWidth = oneChineseGlyphWidth * CGFloat(text.getReadingLength()) + 20
            } else {
                textWidth = accurateWidth()
            }
        }
        var returnWidth: CGFloat = 0
        if textWidth < defaultCandidateCellWidth {
            returnWidth = defaultCandidateCellWidth
        } else {
            returnWidth = textWidth
        }
        return CGSize(width: returnWidth, height: getCandidateCellHeight())
    }
}
