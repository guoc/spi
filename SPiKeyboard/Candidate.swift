
enum CandidateType {
    case empty, special, english, chinese, onlyText, custom
}

class Candidate {
    let type: CandidateType
    let text: String
    var shuangpinString: String?
    var englishString: String?
    var specialString: String?
    var customString: String?
    
    var queryCode: String {
        get {
            switch type {
            case .empty:
                return ""
            case .special:
                return specialString!
            case .english:
                return englishString!
            case .chinese:
                return shuangpinString!
            case .custom:
                return customString!
            default:
                fatalError("Wrong candidate type!")
            }
        }
    }
    
    var lengthAttribute: Int {
        get {
            switch type {
            case .empty:
                return 0
            case .chinese, .english, .special, .custom:
                return queryCode.getReadingLength()
            default:
                fatalError("Wrong candidate type!")
            }
        }
    }
    
    var shuangpinAttributeString: String {
        get {
            switch type {
            case .empty:
                return ""
            case .special:
                return specialString!
            case .english:
                return englishString!
            case .chinese:
                return shuangpinString!
            case .custom:
                return customString!
            default:
                fatalError("Wrong candidate type!")
            }
        }
    }
    
    var shengmuAttributeString: String {
        get {
            switch type {
            case .empty:
                return ""
            case .special:
                return String(specialString![specialString!.startIndex])
            case .english:
                return String(englishString![englishString!.startIndex]).lowercased()
            case .chinese:
                return getShengmuString(from: shuangpinString!)
            case .custom:
                return String(customString![customString!.startIndex]).lowercased()    // For special symbol, lowercaseString does not return different value.
            default:
                fatalError("Wrong candidate type!")
            }
        }
    }
    
    var typeAttributeString: String {
        get {
            switch type {
            case .special:
                return String(3)
            case .english:
                return String(2)
            case .chinese:
                return String(1)
            case .custom:
                return String(4)
            default:
                fatalError("Wrong candidate type!")
            }
        }
    }
    
    init(text: String) {
        self.type = .onlyText
        self.text = text
    }
    
    init(text: String, withShuangpinString shuangpin: String) {
        self.type = .chinese
        self.text = text
        self.shuangpinString = shuangpin
    }
    
    init(text: String, withEnglishString english: String) {
        self.type = .english
        self.text = text
        self.englishString = english
    }
    
    init(text: String, withSpecialString special: String) {
        self.type = .special
        self.text = text
        self.specialString = special
    }
    
    init(text: String, withCustomString custom: String) {
        self.type = .custom
        self.text = text
        self.customString = custom
    }
    
    init(text: String, type: CandidateType, queryString: String) {
        switch type {
        case .empty:
            fatalError("Candidate init fail!")
        case .special:
            self.type = .special
            self.text = text
            self.specialString = queryString
        case .english:
            self.type = .english
            self.text = text
            self.englishString = queryString
        case .chinese:
            self.type = .chinese
            self.text = text
            self.shuangpinString = queryString
        case .custom:
            self.type = .custom
            self.text = text
            self.customString = queryString
        default:
            fatalError("Wrong candidate type!")
        }
    }
    
    convenience init(text: String, queryString: String, isCustomCandidate: Bool) {
        let type = text.getCandidateType()
        self.init(text: text, type: isCustomCandidate ? .custom : type, queryString: queryString)
    }
    
}
