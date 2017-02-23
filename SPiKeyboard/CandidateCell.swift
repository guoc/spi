
import UIKit

func getCandidateCellHeight() -> CGFloat {
    return showTypingCellInExtraLine ? typingAndCandidatesViewHeightWhenShowTypingCellInExtraLineIsTrue : typingAndCandidatesViewHeightWhenShowTypingCellInExtraLineIsFalse
}

var candidateTextFont = UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyle.body), size: 20)

let oneChineseGlyphWidth = ("镜" as NSString).boundingRect(with: CGSize(width: CGFloat.infinity, height: candidatesTableCellHeight), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: candidateTextFont], context: nil).width

class CandidateCell: UICollectionViewCell {
    
    var textLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        selectedBackgroundView = UIView(frame: frame)
        selectedBackgroundView?.autoresizingMask = .flexibleWidth
        selectedBackgroundView?.backgroundColor = UIColor.lightGray

        textLabel = UILabel()
        textLabel.font = candidateTextFont
        textLabel.textAlignment = .center
        textLabel.baselineAdjustment = .alignCenters
        textLabel.lineBreakMode = .byTruncatingTail
        contentView.addSubview(textLabel)
        
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        let constraints = NSLayoutConstraint.constraints(withVisualFormat: "|-8-[textLabel]-8-|", options: [], metrics: nil, views: ["textLabel": textLabel])
        self.contentView.addConstraints(constraints)
        let constraint = NSLayoutConstraint(item: textLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0)
        self.contentView.addConstraint(constraint)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func updateAppearance() {
        if candidatesBannerAppearanceIsDark == true {
            textLabel.textColor = UIColor.white
        } else {
            textLabel.textColor = UIColor.darkText
        }
    }
    
    class func getCellSizeByText(_ text: String, needAccuracy: Bool) -> CGSize {
        
        func accurateWidth() -> CGFloat {
            return (text as NSString).boundingRect(with: CGSize(width: CGFloat.infinity, height: getCandidateCellHeight()), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: candidateTextFont], context: nil).width + 20
        }
        
        var textWidth: CGFloat = 0
        if needAccuracy {
            textWidth = accurateWidth()
        } else {
            let length = text.getReadingLength()
            let utf8Length = text.lengthOfBytes(using: String.Encoding.utf8)
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
