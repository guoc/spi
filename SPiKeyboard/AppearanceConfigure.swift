
func getKeyboardKeyDisplayText(keyText: String) -> String {
    return keyboardKeyDisplayText[keyText] ?? keyText
}

let keyboardKeyDisplayText: [String: String] = [
    "：": ":",
    "；": ";",
    "（": "(",
    "）": ")",
    "。": "  。",
    "，": "  ，",
    "、": "  、",
    "？": "?",
    "！": "!",
    "［": "[",
    "］": "]",
    "｛": "{",
    "｝": "}",
    "《": "≪",
    "》": "≫"
]
