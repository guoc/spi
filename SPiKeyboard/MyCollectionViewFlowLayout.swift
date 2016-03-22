
import UIKit

let defaultCandidateCellWidth: CGFloat = 40
let maxLetterWidth: CGFloat = 20

class MyCollectionViewFlowLayout: UICollectionViewFlowLayout {

    var layoutAttributesS: [UICollectionViewLayoutAttributes]!

    /* Calculated by adding diff, no need calculate in the didSet of candidateCellWidths */
    var widthOfAllCandidateCells: CGFloat = defaultCandidateCellWidth
    var candidateCellWidths: [CGFloat] = [defaultCandidateCellWidth]
    
    override init() {

        super.init()
        scrollDirection = .Horizontal
        itemSize = CGSize(width: defaultCandidateCellWidth, height: getCandidateCellHeight())
        minimumLineSpacing = 0
        resetLayoutAttributeFrames()
    }
    
    init(allCellSize: [CGSize]) {
        
        super.init()
        resetLayoutWithAllCellSize(allCellSize)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func resetAllCellWidth(widths: [CGFloat]) {
        
        candidateCellWidths = widths
        widthOfAllCandidateCells = candidateCellWidths.reduce(0, combine: +)
    }
    
    func resetLayoutAttributeFrames() {
        
        layoutAttributesS = [UICollectionViewLayoutAttributes]()
        let zerothLayoutAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        zerothLayoutAttributes.frame = CGRect(x: 0, y: 0, width: candidateCellWidths[0], height: getCandidateCellHeight())
        layoutAttributesS.append(zerothLayoutAttributes)
        let lastIndex = self.candidateCellWidths.count - 1
        if lastIndex >= 1 {
            for index in 1...lastIndex {
                let currentLayoutAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: NSIndexPath(forRow: index, inSection: 0))
                let prevLayoutAttributes = layoutAttributesS[index - 1]
                let maximumSpacing: CGFloat = 0
                let origin = CGRectGetMaxX(prevLayoutAttributes.frame)
                if origin + maximumSpacing + currentLayoutAttributes.frame.size.width < self.collectionViewContentSize().width {
                    var frame = currentLayoutAttributes.frame
                    frame.origin.x = origin + maximumSpacing
                    frame.size.width = candidateCellWidths[index]
                    frame.size.height = getCandidateCellHeight()
                    currentLayoutAttributes.frame = frame
                } else {
                    // TODO
                }
                layoutAttributesS.append(currentLayoutAttributes)
            }
        }
    }
    

    
    override func collectionViewContentSize() -> CGSize {
        
        return CGSize(width: widthOfAllCandidateCells, height: itemSize.height)
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var index = 0
        let lengthOfLayoutAttributesS = layoutAttributesS.count
        var returnAttributesS = [UICollectionViewLayoutAttributes]()
        while index < lengthOfLayoutAttributesS && layoutAttributesS[index].frame.maxX < rect.minX {
            index += 1
        }
        while index < lengthOfLayoutAttributesS && layoutAttributesS[index].frame.minX <= rect.maxX {
            returnAttributesS.append(layoutAttributesS[index])
            index += 1
        }
        
        return returnAttributesS
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        
        return layoutAttributesS[indexPath.row]
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        // TODO
        return false
    }
    
    func updateLayoutRaisedByCellAt(indexPath: NSIndexPath, withCellSize size: CGSize) {
        
        if showTypingCellInExtraLine == true && indexPath == indexPathZero {
            return
        }
        
        if indexPath.row < candidateCellWidths.count {
            let originalWidth = candidateCellWidths[indexPath.row]
            if ceil(originalWidth) != ceil(size.width) {
                let diff = size.width - originalWidth
                candidateCellWidths[indexPath.row] += diff
                layoutAttributesS[indexPath.row].frame.size.width += diff
                widthOfAllCandidateCells += diff
                let lastIndex = candidateCellWidths.count
                for index in (indexPath.row + 1)..<lastIndex {
                    layoutAttributesS[index].frame.origin.x += diff
                }
            }
        }
    }
    
    func resetLayoutWithAllCellSize(sizes: [CGSize]) {
        var sizes = sizes.map({x in x.width})
        if showTypingCellInExtraLine == true {
            sizes[0] = 0
        }
        resetAllCellWidth(sizes)
        resetLayoutAttributeFrames()
    }
}
