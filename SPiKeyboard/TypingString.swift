
enum FormalizedTypingStringType {
    case empty, englishOrShuangpin, english, special
}

class FormalizedTypingString {
    
    let type: FormalizedTypingStringType
    let string: String
    let originalString: String
    
    init() {
        self.type = .empty
        self.string = ""
        self.originalString = ""
    }
    
    init(type: FormalizedTypingStringType, originalString: String, string: String) {
        self.type = type
        self.originalString = originalString
        self.string = string
    }
}

class TypingString {
  
    var userTypingString: String {
        didSet {
            resetCacheProperty()
        }
    }
    var _cachedCandidatesWithCorrespondingTyping: [(candidate: Candidate, typing: String)] = [] {
        didSet {
            resetCacheProperty()
        }
    }
    
    // Properties for cache computed properties
    func resetCacheProperty() {
        _remainingDisplayedShuangpinString = nil
        _displayedString = nil
        _remainingUserTypingString = nil
        _remainingFormalizedTypingStringForQuery = nil
        _joinedCandidate = nil
    }
    var _remainingDisplayedShuangpinString: String? = nil
    var _displayedString: String? = nil
    var _remainingUserTypingString: String? = nil
    var _remainingFormalizedTypingStringForQuery: FormalizedTypingString? = nil
    var _joinedCandidate: String? = nil
    
    var remainingDisplayedShuangpinString: String {
        get {
            if _remainingDisplayedShuangpinString == nil {
                _remainingDisplayedShuangpinString = getFormalizedTypingString(remainingUserTypingString, byScheme: ShuangpinScheme.getScheme(), forDisplay: true).string
            }
            return _remainingDisplayedShuangpinString!
        }
    }
    
    var displayedString: String {
        get {
            if _displayedString == nil {
                _displayedString = joinedCandidate + remainingDisplayedShuangpinString
            }
            return _displayedString!
        }
    }
    
    var remainingUserTypingString: String {
        get {
            if _remainingUserTypingString == nil {
                let wordLengthOfAllCachedCandidateTypings = _cachedCandidatesWithCorrespondingTyping.reduce(0, {(s: Int, x: (candidate: Candidate, typing: String)) -> Int in return s + x.typing.getReadingLength()})
                _remainingUserTypingString = userTypingString.substring(from: userTypingString.characters.index(userTypingString.startIndex, offsetBy: wordLengthOfAllCachedCandidateTypings))
            }
            return _remainingUserTypingString!
        }
    }
    
    var remainingFormalizedTypingStringForQuery: FormalizedTypingString {
        get {
            if _remainingFormalizedTypingStringForQuery == nil {
                _remainingFormalizedTypingStringForQuery = getFormalizedTypingString(remainingUserTypingString, byScheme: ShuangpinScheme.getScheme(), forDisplay: false)
            }
            return _remainingFormalizedTypingStringForQuery!
        }
    }
    
    var joinedCandidate: String {
        get {
            if _joinedCandidate == nil {
                _joinedCandidate = _cachedCandidatesWithCorrespondingTyping.map({x in return x.candidate.text}).joined(separator: "")
            }
            return _joinedCandidate!
        }
    }
    
    var typeOfRemainingFormalizedTyping: FormalizedTypingStringType {
        get {
            return self.remainingFormalizedTypingStringForQuery.type
        }
    }
    
    init() {
        userTypingString = ""
    }
    
    init(userTypingString: String) {
        self.userTypingString = userTypingString
    }
    
    func reset() {
        userTypingString = ""
        _cachedCandidatesWithCorrespondingTyping = []
    }
    
    func append(_ newString: String) {
        userTypingString += newString
    }
    
    func popOneCachedCandidate() {
        let _ = (_cachedCandidatesWithCorrespondingTyping.last as (candidate: Candidate, typing: String)?)!.typing
        _cachedCandidatesWithCorrespondingTyping.removeLast()
    }
    
    func popAllCachedCandidates() {
        while _cachedCandidatesWithCorrespondingTyping.isEmpty == false {
            popOneCachedCandidate()
        }
    }
    
    func deleteLast() {
        if _cachedCandidatesWithCorrespondingTyping.isEmpty {
            userTypingString = String(userTypingString.characters.dropLast())
        } else {
            popOneCachedCandidate()
        }
    }
    
    func hasSelectedPartialCandidates() -> Bool {
        if _cachedCandidatesWithCorrespondingTyping.isEmpty == false && remainingDisplayedShuangpinString != "" {
            return true
        } else {
            return false
        }
    }
    
    func isEmpty() -> Bool {
        return (userTypingString == "")
    }
    
    func readyToInsert() -> Bool {
        if remainingUserTypingString == "" && _cachedCandidatesWithCorrespondingTyping.isEmpty == false {
            return true
        } else {
            return false
        }
    }
    
    func getCandidate() -> Candidate {
        if typeOfRemainingFormalizedTyping == .empty && _cachedCandidatesWithCorrespondingTyping.isEmpty == false {
            if _cachedCandidatesWithCorrespondingTyping.count == 1 {
                let (candidate, queryString) = _cachedCandidatesWithCorrespondingTyping[0]
                let type = candidate.type
                if type != .chinese {
                    return Candidate(text: candidate.text, type: type, queryString: queryString)
                }
            }
            return Candidate(text: _cachedCandidatesWithCorrespondingTyping.map({x -> String in return x.candidate.text}).joined(separator: ""), withShuangpinString: _cachedCandidatesWithCorrespondingTyping.map({x -> String in return x.candidate.queryCode}).joined(separator: " "))
        } else if hasSelectedPartialCandidates() {
            return Candidate(text: _cachedCandidatesWithCorrespondingTyping.map({x -> String in return x.candidate.text}).joined(separator: ""))
        } else {
            return Candidate(text: userTypingString, withEnglishString: userTypingString.lowercased())
        }
    }
    
    func updateBySelectedCandidate(_ candidate: Candidate) {
        switch candidate.type {
        case .empty:
            assertionFailure("Wrong branch!")
        case .english, .special, .onlyText, .custom:
            assert(_cachedCandidatesWithCorrespondingTyping.isEmpty, "_cachedCandidatesWithCorrespondingTyping: \(_cachedCandidatesWithCorrespondingTyping) should be empty!")
            let newCandidateWithCorrespondingTyping = (candidate: candidate, typing: userTypingString)
            _cachedCandidatesWithCorrespondingTyping.append(newCandidateWithCorrespondingTyping)
        case .chinese:
            assert(self.typeOfRemainingFormalizedTyping == .englishOrShuangpin, "typeOfRemainingFormalizedTyping should be .EnglishOrShuangpin")
            let numberOfWords = candidate.text.getReadingLength()
            // Get how many "_" in the pinyin of candidate
            let candidateShuangpinArray = remainingFormalizedTypingStringForQuery.string.components(separatedBy: CharacterSet.whitespaces)
            let numberOfUnderscore = candidateShuangpinArray[0..<min(numberOfWords, candidateShuangpinArray.count)].reduce(0, { $0 + ($1.characters.contains("_") ? 1 : 0) })
            // Get end
            let truncatingLength = numberOfWords * 2 - numberOfUnderscore
            if  truncatingLength < remainingUserTypingString.getReadingLength() {
                let index = remainingUserTypingString.characters.index(remainingUserTypingString.startIndex, offsetBy: truncatingLength)
                _cachedCandidatesWithCorrespondingTyping.append((candidate: candidate, typing: remainingUserTypingString.substring(to: index)))
            } else {
                _cachedCandidatesWithCorrespondingTyping.append((candidate: candidate, typing: remainingUserTypingString.substring(to: remainingUserTypingString.endIndex)))
            }
        }
    }
    
    func getFormalizedTypingString(_ userTypingString: String, byScheme scheme: [String: String], forDisplay useForDisply: Bool) -> FormalizedTypingString {
        
        if userTypingString == "" {
            return FormalizedTypingString()
        }
        
        if userTypingString.containsNonLetters() {    // no matter for display or not
            return FormalizedTypingString(type: .special, originalString: userTypingString, string: userTypingString)
        } else if userTypingString.containsUppercaseLetters() == true {
            return FormalizedTypingString(type: .english, originalString: userTypingString, string: userTypingString)
        } else {
            // EnglishOrShuangpin
            let userTyping = userTypingString as NSString
            let length = userTyping.length
            var formalizedStr = ""
            var index = 0
            while index < length - 1 {
                let twoLetters = userTyping.substring(with: NSMakeRange(index,2))
                let newTwoLetters = scheme[twoLetters]
                if newTwoLetters != nil {
                    formalizedStr += useForDisply ? twoLetters : newTwoLetters!
                    index += 2
                } else {
                    let fst = userTyping.substring(with: NSMakeRange(index,1))
                    let newFst = scheme[String(fst)]!
                    formalizedStr += useForDisply ? fst: newFst
                    formalizedStr += useForDisply ? "" : "_"
                    index += 1
                }
                if index < length {
                    formalizedStr += " "
                }
            }
            if index < length {
                let fst = userTyping.substring(with: NSMakeRange(index,1))
                let newFst = scheme[String(fst)]!
                formalizedStr += useForDisply ? fst : newFst
            }
            
            return formalizedStr == "" ? FormalizedTypingString() : FormalizedTypingString(type: .englishOrShuangpin, originalString: userTypingString, string: formalizedStr)
        }
    }
}
