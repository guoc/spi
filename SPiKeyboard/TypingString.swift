
enum FormalizedTypingStringType {
    case Empty, EnglishOrShuangpin, English, Special
}

class FormalizedTypingString {
    
    let type: FormalizedTypingStringType
    let string: String
    
    init() {
        self.type = .Empty
        self.string = ""
    }
    
    init(type: FormalizedTypingStringType, string: String) {
        self.type = type
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
                let wordLengthOfAllCachedCandidateTypings = _cachedCandidatesWithCorrespondingTyping.reduce(0, combine: {(s: Int, x: (candidate: Candidate, typing: String)) -> Int in return s + x.typing.getReadingLength()})
                _remainingUserTypingString = userTypingString.substringFromIndex(advance(userTypingString.startIndex, wordLengthOfAllCachedCandidateTypings))
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
                _joinedCandidate = "".join(_cachedCandidatesWithCorrespondingTyping.map({x in return x.candidate.text}))
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
    
    func append(newString: String) {
        userTypingString += newString
    }
    
    func popOneCachedCandidate() {
        let cachedTyping = (_cachedCandidatesWithCorrespondingTyping.last as (candidate: Candidate, typing: String)?)!.typing
        _cachedCandidatesWithCorrespondingTyping.removeLast()
    }
    
    func popAllCachedCandidates() {
        while _cachedCandidatesWithCorrespondingTyping.isEmpty == false {
            popOneCachedCandidate()
        }
    }
    
    func deleteLast() {
        if _cachedCandidatesWithCorrespondingTyping.isEmpty {
            userTypingString = dropLast(userTypingString)
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
        if userTypingString.containsNonLetters() == true {
            return Candidate(text: userTypingString, withSpecialString: userTypingString)
        } else if typeOfRemainingFormalizedTyping == .Empty && _cachedCandidatesWithCorrespondingTyping.isEmpty == false {
            return Candidate(text: "".join(_cachedCandidatesWithCorrespondingTyping.map({x -> String in return x.candidate.text})), withShuangpinString: " ".join(_cachedCandidatesWithCorrespondingTyping.map({x -> String in return x.candidate.queryCode})))
        } else if hasSelectedPartialCandidates() {
            return Candidate(text: "".join(_cachedCandidatesWithCorrespondingTyping.map({x -> String in return x.candidate.text})))
        } else {
            return Candidate(text: userTypingString, withEnglishString: userTypingString.lowercaseString)
        }
    }
    
    func updateBySelectedCandidate(candidate: Candidate) {
        switch candidate.type {
        case .Empty:
            assertionFailure("Wrong branch!")
        case .English, .Special, .OnlyText:
            assert(_cachedCandidatesWithCorrespondingTyping.isEmpty, "_cachedCandidatesWithCorrespondingTyping: \(_cachedCandidatesWithCorrespondingTyping) should be empty!")
            let newCandidateWithCorrespondingTyping = (candidate: candidate, typing: userTypingString)
            _cachedCandidatesWithCorrespondingTyping.append(newCandidateWithCorrespondingTyping)
        case .Chinese:
            assert(self.typeOfRemainingFormalizedTyping == .EnglishOrShuangpin, "typeOfRemainingFormalizedTyping should be .EnglishOrShuangpin")
            let numberOfWords = candidate.text.getReadingLength()
            // Get how many "_" in the pinyin of candidate
            let candidateShuangpinArray = remainingFormalizedTypingStringForQuery.string.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            let numberOfUnderscore = candidateShuangpinArray[0..<min(numberOfWords, candidateShuangpinArray.count)].reduce(0, { $0 + (contains($1, "_") ? 1 : 0) })
            // Get end
            let truncatingLength = numberOfWords * 2 - numberOfUnderscore
            if  truncatingLength < remainingUserTypingString.getReadingLength() {
                let index = advance(remainingUserTypingString.startIndex, truncatingLength)
                _cachedCandidatesWithCorrespondingTyping.append((candidate: candidate, typing: remainingUserTypingString.substringToIndex(index)))
            } else {
                _cachedCandidatesWithCorrespondingTyping.append((candidate: candidate, typing: remainingUserTypingString.substringToIndex(remainingUserTypingString.endIndex)))
            }
        }
    }
    
    func getFormalizedTypingString(userTypingString: String, byScheme scheme: [String: String], forDisplay useForDisply: Bool) -> FormalizedTypingString {
        
        if userTypingString == "" {
            return FormalizedTypingString()
        }
        
        //        func getEnglishWord(str: String) -> String? {
        //            let guessedWords = textChecker.guessesForWordRange(NSMakeRange(0, str.getReadingLength()), inString: str, language: "en")
        //            if guessedWords!.isEmpty {
        //                return nil
        //            }
        //            let guess = guessedWords![0] as String
        //            if guess.caseInsensitiveCompare(str) == NSComparisonResult.OrderedSame {
        //                return guess
        //            } else {
        //                return nil
        //            }
        //        }
        //
        //        if let word = getEnglishWord(userTypingString) {
        //            return useForDisply ? FormalizedTypingString(type: .English, string: userTypingString) : FormalizedTypingString(type: .English, string: word)
        //        }
        
        if userTypingString.onlyContainsLowercaseLetters() == false {    // no matter for display or not
            return FormalizedTypingString(type: .Special, string: userTypingString)
        } else if userTypingString.containsUppercaseLetters() == true {
            return FormalizedTypingString(type: .English, string: userTypingString)
        } else {
            // EnglishOrShuangpin
            var userTyping = userTypingString as NSString
            let length = userTyping.length
            var formalizedStr = ""
            var index = 0
            while index < length - 1 {
                let twoLetters = userTyping.substringWithRange(NSMakeRange(index,2))
                let newTwoLetters = scheme[twoLetters]
                if newTwoLetters != nil {
                    formalizedStr += useForDisply ? twoLetters : newTwoLetters!
                    index += 2
                } else {
                    let fst = userTyping.substringWithRange(NSMakeRange(index,1))
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
                let fst = userTyping.substringWithRange(NSMakeRange(index,1))
                let newFst = scheme[String(fst)]!
                formalizedStr += useForDisply ? fst : newFst
            }
            
            return formalizedStr == "" ? FormalizedTypingString() : FormalizedTypingString(type: .EnglishOrShuangpin, string: formalizedStr)
        }
    }
}
