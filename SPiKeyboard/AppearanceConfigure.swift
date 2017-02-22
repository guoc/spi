
func getKeyboardKeyDisplayText(_ keyText: String) -> String {
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
    "【": "【  ",
    "】": "  】",
    "｛": "{",
    "｝": "}",
    "《": "≪",
    "》": "≫"
]
