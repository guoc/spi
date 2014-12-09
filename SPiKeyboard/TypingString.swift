
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
    
    var _formalizedTypingStringForQuery: FormalizedTypingString? = nil
    var _remainingDisplayedShuangpinString: String? = nil
    
    var cachedCandidates: [(candidate: String, typing: String)] = []
    
    var userTypingString: String {
        didSet {
            _formalizedTypingStringForQuery = nil
            _remainingDisplayedShuangpinString = nil
        }
    }
    
    var displayedString: String {
        get {
            if _remainingDisplayedShuangpinString == nil {
                _remainingDisplayedShuangpinString = joinedCandidate + getFormalizedTypingString(userTypingString, byScheme: ShuangpinScheme.getScheme(), forDisplay: true).string
            }
            return _remainingDisplayedShuangpinString!
        }
    }
    
    var formalizedTypingStringForQuery: FormalizedTypingString {
        get {
            if _formalizedTypingStringForQuery == nil {
                _formalizedTypingStringForQuery = getFormalizedTypingString(userTypingString, byScheme: ShuangpinScheme.getScheme(), forDisplay: false)
            }
            return _formalizedTypingStringForQuery!
        }
    }
    
    var joinedCandidate: String {
        get {
            return "".join(cachedCandidates.map({x in return x.candidate}))
        }
    }
    
    var type: FormalizedTypingStringType {
        get {
            return self.formalizedTypingStringForQuery.type
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
        _formalizedTypingStringForQuery = nil
        _remainingDisplayedShuangpinString = nil
        cachedCandidates = []
    }
    
    func append(newString: String) {
        userTypingString += newString
    }
    
    func deleteLast() {
        if cachedCandidates.isEmpty {
            userTypingString = dropLast(userTypingString)
        } else {
            let cachedCandidate = (cachedCandidates.last as (candidate: String, typing: String)?)!.candidate
            let cachedTyping = (cachedCandidates.last as (candidate: String, typing: String)?)!.typing
            userTypingString = cachedTyping + userTypingString
            cachedCandidates.removeLast()
        }
    }
    
    func isEmpty() -> Bool {
        return (userTypingString == "")
    }
    
    func readyToInsert() -> Bool {
        if userTypingString == "" {
            return true
        } else {
            return false
        }
    }
    
    func updateBySelectedCandidateText(candidateText: String) {
        let numberOfWords = candidateText.getReadingLength()
        if self.type == .Special {
            reset()
        } else if self.type == .EnglishOrShuangpin {    // See caller, it only could be Shuangpin
            // Get how many "_" in the pinyin of candidate
            let candidateShuangpinArray = formalizedTypingStringForQuery.string.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            let numberOfUnderscore = candidateShuangpinArray[0..<min(numberOfWords, candidateShuangpinArray.count)].reduce(0, { $0 + (contains($1, "_") ? 1 : 0) })
            // Get end
            let truncatingLength = numberOfWords * 2 - numberOfUnderscore
            if  truncatingLength < userTypingString.getReadingLength() {
                let index = advance(userTypingString.startIndex, truncatingLength)
                cachedCandidates.append((candidate: candidateText, typing: userTypingString.substringToIndex(index)))
                userTypingString = userTypingString.substringFromIndex(index)
            } else {
                cachedCandidates.append((candidate: candidateText, typing: userTypingString.substringToIndex(userTypingString.endIndex)))
                userTypingString = ""
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
