
import UIKit

class TypingLabel: UILabel {
    
    override func drawTextInRect(rect: CGRect) {
        let insets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, insets))
    }

    func updateAppearance() {
        if candidatesBannerAppearanceIsDark == true {
            self.textColor = UIColor.whiteColor()
        } else {
            self.textColor = UIColor.darkTextColor()
        }
    }
    
}
