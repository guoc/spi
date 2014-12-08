
import Foundation

/// The dictionary of ZiranmaShengmu: QuanpinShengmu
let Shengmu = [
    "a": "a",
    "e": "e",
    "o": "o",
    "i": "ch",
    "b": "b",
    "c": "c",
    "d": "d",
    "f": "f",
    "g": "g",
    "h": "h",
    "j": "j",
    "k": "k",
    "l": "l",
    "m": "m",
    "n": "n",
    "p": "p",
    "q": "q",
    "r": "r",
    "s": "s",
    "t": "t",
    "u": "sh",
    "v": "zh",
    "w": "w",
    "x": "x",
    "y": "y",
    "z": "z"
]

/// The array of all yunmu
let Yunmu = ["ou", "iao", "uang", "iang", "en", "eng", "ang", "i", "an", "ao", "ai", "ian", "in", "o", "uo", "un", "iu", "uan", "iong", "ong", "ue", "u", "ui", "v", "ua", "ia", "ie", "uai", "ing", "ei",
"m", "n", "g"]

/// The dictionary of StandardizedShuangpin: Quanpin
let Quanpin = [
    "ba": "ba",
    "bc": "biao",
    "bf": "ben",
    "bg": "beng",
    "bh": "bang",
    "bi": "bi",
    "bj": "ban",
    "bk": "bao",
    "bl": "bai",
    "bm": "bian",
    "bn": "bin",
    "bo": "bo",
    "bu": "bu",
    "bx": "bie",
    "by": "bing",
    "bz": "bei",
    
    "ca": "ca",
    "cb": "cou",
    "ce": "ce",
    "cf": "cen",
    "cg": "ceng",
    "ch": "cang",
    "ci": "ci",
    "cj": "can",
    "ck": "cao",
    "cl": "cai",
    "co": "cuo",
    "cp": "cun",
    "cr": "cuan",
    "cs": "cong",
    "cu": "cu",
    "cv": "cui",
    
    "da": "da",
    "db": "dou",
    "dc": "diao",
    "de": "de",
    "df": "den",
    "dg": "deng",
    "dh": "dang",
    "di": "di",
    "dj": "dan",
    "dk": "dao",
    "dl": "dai",
    "dm": "dian",
    "do": "duo",
    "dp": "dun",
    "dq": "diu",
    "dr": "duan",
    "ds": "dong",
    "du": "du",
    "dv": "dui",
    "dw": "dia",
    "dx": "die",
    "dy": "ding",
    "dz": "dei",
    
    "fa": "fa",
    "fb": "fou",
    "fc": "fiao",
    "ff": "fen",
    "fg": "feng",
    "fh": "fang",
    "fj": "fan",
    "fo": "fo",
    "fs": "fong",
    "fu": "fu",
    "fz": "fei",
    
    "ga": "ga",
    "gb": "gou",
    "gd": "guang",
    "ge": "ge",
    "gf": "gen",
    "gg": "geng",
    "gh": "gang",
    "gj": "gan",
    "gk": "gao",
    "gl": "gai",
    "go": "guo",
    "gp": "gun",
    "gr": "guan",
    "gs": "gong",
    "gu": "gu",
    "gv": "gui",
    "gw": "gua",
    "gy": "guai",
    "gz": "gei",
    
    "ha": "ha",
    "hb": "hou",
    "hd": "huang",
    "he": "he",
    "hf": "hen",
    "hg": "heng",
    "hh": "hang",
    "hj": "han",
    "hk": "hao",
    "hl": "hai",
    "ho": "huo",
    "hp": "hun",
    "hr": "huan",
    "hs": "hong",
    "hu": "hu",
    "hv": "hui",
    "hw": "hua",
    "hy": "huai",
    "hz": "hei",
    
    "ia": "cha",
    "ib": "chou",
    "id": "chuang",
    "ie": "che",
    "if": "chen",
    "ig": "cheng",
    "ih": "chang",
    "ii": "chi",
    "ij": "chan",
    "ik": "chao",
    "il": "chai",
    "io": "chuo",
    "ip": "chun",
    "ir": "chuan",
    "is": "chong",
    "iu": "chu",
    "iv": "chui",
    "iw": "chua",
    "iy": "chuai",
    
    "jc": "jiao",
    "jd": "jiang",
    "ji": "ji",
    "jm": "jian",
    "jn": "jin",
    "jp": "jun",
    "jq": "jiu",
    "jr": "juan",
    "js": "jiong",
    "jt": "jue",
    "ju": "ju",
    "jw": "jia",
    "jx": "jie",
    "jy": "jing",
    
    "ka": "ka",
    "kb": "kou",
    "kd": "kuang",
    "ke": "ke",
    "kf": "ken",
    "kg": "keng",
    "kh": "kang",
    "kj": "kan",
    "kk": "kao",
    "kl": "kai",
    "ko": "kuo",
    "kp": "kun",
    "kr": "kuan",
    "ks": "kong",
    "ku": "ku",
    "kv": "kui",
    "kw": "kua",
    "ky": "kuai",
    "kz": "kei",
    
    "la": "la",
    "lb": "lou",
    "lc": "liao",
    "ld": "liang",
    "le": "le",
    "lg": "leng",
    "lh": "lang",
    "li": "li",
    "lj": "lan",
    "lk": "lao",
    "ll": "lai",
    "lm": "lian",
    "ln": "lin",
    "lo": "luo",
    "lp": "lun",
    "lq": "liu",
    "lr": "luan",
    "ls": "long",
    "lt": "lue",
    "lu": "lu",
    "lv": "lv",
    "lw": "lia",
    "lx": "lie",
    "ly": "ling",
    "lz": "lei",
    
    "ma": "ma",
    "mb": "mou",
    "mc": "miao",
    "me": "me",
    "mf": "men",
    "mg": "meng",
    "mh": "mang",
    "mi": "mi",
    "mj": "man",
    "mk": "mao",
    "ml": "mai",
    "mm": "mian",
    "mn": "min",
    "mo": "mo",
    "mq": "miu",
    "mu": "mu",
    "mx": "mie",
    "my": "ming",
    "mz": "mei",
    
    "na": "na",
    "nb": "nou",
    "nc": "niao",
    "nd": "niang",
    "ne": "ne",
    "nf": "nen",
    "ng": "neng",
    "nh": "nang",
    "ni": "ni",
    "nj": "nan",
    "nk": "nao",
    "nl": "nai",
    "nm": "nian",
    "nn": "nin",
    "no": "nuo",
    "np": "nun",
    "nq": "niu",
    "nr": "nuan",
    "ns": "nong",
    "nt": "nue",
    "nu": "nu",
    "nv": "nv",
    "nw": "nia",
    "nx": "nie",
    "ny": "ning",
    "nz": "nei",
    
    "oa": "a",
    "ob": "ou",
    "oe": "e",
    "of": "en",
    "og": "eng",
    "oh": "ang",
    "oj": "an",
    "ok": "ao",
    "ol": "ai",
    "oo": "o",
    "or": "er",
    "oz": "ei",
    
    "pa": "pa",
    "pb": "pou",
    "pc": "piao",
    "pf": "pen",
    "pg": "peng",
    "ph": "pang",
    "pi": "pi",
    "pj": "pan",
    "pk": "pao",
    "pl": "pai",
    "pm": "pian",
    "pn": "pin",
    "po": "po",
    "pu": "pu",
    "px": "pie",
    "py": "ping",
    "pz": "pei",
    
    "qc": "qiao",
    "qd": "qiang",
    "qi": "qi",
    "qm": "qian",
    "qn": "qin",
    "qp": "qun",
    "qq": "qiu",
    "qr": "quan",
    "qs": "qiong",
    "qt": "que",
    "qu": "qu",
    "qw": "qia",
    "qx": "qie",
    "qy": "qing",
    
    "rb": "rou",
    "re": "re",
    "rf": "ren",
    "rg": "reng",
    "rh": "rang",
    "ri": "ri",
    "rj": "ran",
    "rk": "rao",
    "ro": "ruo",
    "rp": "run",
    "rr": "ruan",
    "rs": "rong",
    "ru": "ru",
    "rv": "rui",
    
    "sa": "sa",
    "sb": "sou",
    "se": "se",
    "sf": "sen",
    "sg": "seng",
    "sh": "sang",
    "si": "si",
    "sj": "san",
    "sk": "sao",
    "sl": "sai",
    "so": "suo",
    "sp": "sun",
    "sr": "suan",
    "ss": "song",
    "su": "su",
    "sv": "sui",
    "sz": "sei",
    
    "ta": "ta",
    "tb": "tou",
    "tc": "tiao",
    "te": "te",
    "tg": "teng",
    "th": "tang",
    "ti": "ti",
    "tj": "tan",
    "tk": "tao",
    "tl": "tai",
    "tm": "tian",
    "to": "tuo",
    "tp": "tun",
    "tr": "tuan",
    "ts": "tong",
    "tu": "tu",
    "tv": "tui",
    "tx": "tie",
    "ty": "ting",
    "tz": "tei",
    
    "ua": "sha",
    "ub": "shou",
    "ud": "shuang",
    "ue": "she",
    "uf": "shen",
    "ug": "sheng",
    "uh": "shang",
    "ui": "shi",
    "uj": "shan",
    "uk": "shao",
    "ul": "shai",
    "uo": "shuo",
    "up": "shun",
    "ur": "shuan",
    "uu": "shu",
    "uv": "shui",
    "uw": "shua",
    "uy": "shuai",
    "uz": "shei",
    
    "va": "zha",
    "vb": "zhou",
    "vd": "zhuang",
    "ve": "zhe",
    "vf": "zhen",
    "vg": "zheng",
    "vh": "zhang",
    "vi": "zhi",
    "vj": "zhan",
    "vk": "zhao",
    "vl": "zhai",
    "vo": "zhuo",
    "vp": "zhun",
    "vr": "zhuan",
    "vs": "zhong",
    "vu": "zhu",
    "vv": "zhui",
    "vw": "zhua",
    "vy": "zhuai",
    "vz": "zhei",
    
    "wa": "wa",
    "wf": "wen",
    "wg": "weng",
    "wh": "wang",
    "wj": "wan",
    "wl": "wai",
    "wo": "wo",
    "wu": "wu",
    "wz": "wei",
    
    "xc": "xiao",
    "xd": "xiang",
    "xi": "xi",
    "xm": "xian",
    "xn": "xin",
    "xp": "xun",
    "xq": "xiu",
    "xr": "xuan",
    "xs": "xiong",
    "xt": "xue",
    "xu": "xu",
    "xw": "xia",
    "xx": "xie",
    "xy": "xing",
    
    "ya": "ya",
    "yb": "you",
    "ye": "ye",
    "yh": "yang",
    "yi": "yi",
    "yj": "yan",
    "yk": "yao",
    "yl": "yai",
    "yn": "yin",
    "yo": "yo",
    "yp": "yun",
    "yr": "yuan",
    "ys": "yong",
    "yt": "yue",
    "yu": "yu",
    "yy": "ying",
    
    "za": "za",
    "zb": "zou",
    "ze": "ze",
    "zf": "zen",
    "zg": "zeng",
    "zh": "zang",
    "zi": "zi",
    "zj": "zan",
    "zk": "zao",
    "zl": "zai",
    "zo": "zuo",
    "zp": "zun",
    "zr": "zuan",
    "zs": "zong",
    "zu": "zu",
    "zv": "zui",
    "zz": "zei",
    
    "lO": "lo", // update database with lo
    "om": "m",
    "on": "n",
    "hm": "hm",
    "nG": "ng"  // update database with ng
]

let Shuangpin: [String: String] = {
    var newDict = [String: String]()
    for s in Quanpin.keys {
        var y: String = Quanpin[s]!
        if let existS = newDict[y]  {
            println("\(existS): \(y) -> \(s): \(y)")
        } else {
            newDict[y] = s
        }
    }
    return newDict
}()

//let YunmusAfterA = ["a", "h", "i", "n", "o"] // 5
let YunmusAfterB = ["a", "c", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "u", "x", "y", "z"] // 16
let YunmusAfterC = ["a", "b", "e", "f", "g", "h", "i", "j", "k", "l", "o", "p", "r", "s", "u", "v"] // 16
let YunmusAfterD = ["a", "b", "c", "e", "f", "g", "h", "i", "j", "k", "l", "m", "o", "p", "q", "r", "s", "u", "v", "w", "x", "y", "z"] // 23
//let YunmusAfterE = ["e", "f", "g", "i", "n", "r"] // 6
let YunmusAfterF = ["a", "b", "c", "f", "g", "h", "j", "o", "s", "u", "z"] // 11
let YunmusAfterG = ["a", "b", "d", "e", "f", "g", "h", "j", "k", "l", "o", "p", "r", "s", "u", "v", "w", "y", "z"] // 19
let YunmusAfterH = ["a", "b", "d", "e", "f", "g", "h", "j", "k", "l", "m", "o", "p", "r", "s", "u", "v", "w", "y", "z"] // 19
let YunmusAfterI = ["a", "b", "d", "e", "f", "g", "h", "i", "j", "k", "l", "o", "p", "r", "s", "u", "v", "w", "y"] // 19
let YunmusAfterJ = ["c", "d", "i", "m", "n", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y"] // 15
let YunmusAfterK = ["a", "b", "d", "e", "f", "g", "h", "j", "k", "l", "o", "p", "r", "s", "u", "v", "w", "y", "z"] // 19
let YunmusAfterL = ["a", "b", "c", "d", "e", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"] // 25
let YunmusAfterM = ["a", "b", "c", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "q", "u", "x", "y", "z"] // 19
let YunmusAfterN = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"] // 26
let YunmusAfterO = ["a", "e", "o", // "u"
"b", "f", "g", "h", "j", "k", "l", "r", "z",
"m"]
let YunmusAfterP = ["a", "b", "c", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "u", "x", "y", "z"] // 17
let YunmusAfterQ = ["c", "d", "i", "m", "n", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y"] // 15
let YunmusAfterR = ["b", "e", "f", "g", "h", "i", "j", "k", "o", "p", "r", "s", "u", "v"] // 14
let YunmusAfterS = ["a", "b", "e", "f", "g", "h", "i", "j", "k", "l", "o", "p", "r", "s", "u", "v", "z"] // 17
let YunmusAfterT = ["a", "b", "c", "e", "g", "h", "i", "j", "k", "l", "m", "o", "p", "r", "s", "u", "v", "x", "y", "z"] // 20
let YunmusAfterU = ["a", "b", "d", "e", "f", "g", "h", "i", "j", "k", "l", "o", "p", "r", "u", "v", "w", "y", "z"] // 19
let YunmusAfterV = ["a", "b", "d", "e", "f", "g", "h", "i", "j", "k", "l", "o", "p", "r", "s", "u", "v", "w", "y", "z"] // 20
let YunmusAfterW = ["a", "f", "g", "h", "j", "l", "o", "u", "z"] // 9
let YunmusAfterX = ["c", "d", "i", "m", "n", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y"] // 15
let YunmusAfterY = ["a", "b", "e", "h", "i", "j", "k", "l", "n", "o", "p", "r", "s", "t", "u", "v", "y"] // 17
let YunmusAfterZ = ["a", "b", "e", "f", "g", "h", "i", "j", "k", "l", "o", "p", "r", "s", "u", "v", "z"] // 17

/// The dictionary of Shengmu: [Yunmu]
let YunmusAfterShengmu = [
//    "a": YunmusAfterA, // 5
    "b": YunmusAfterB, // 16
    "c": YunmusAfterC, // 16
    "d": YunmusAfterD, // 23
//    "e": YunmusAfterE, // 6
    "f": YunmusAfterF, // 11
    "g": YunmusAfterG, // 19
    "h": YunmusAfterH, // 19
    "i": YunmusAfterI, // 19
    "j": YunmusAfterJ, // 15
    "k": YunmusAfterK, // 18
    "l": YunmusAfterL, // 25
    "m": YunmusAfterM, // 19
    "n": YunmusAfterN, // 26
    "o": YunmusAfterO, // 4
    "p": YunmusAfterP, // 17
    "q": YunmusAfterQ, // 15
    "r": YunmusAfterR, // 14
    "s": YunmusAfterS, // 17
    "t": YunmusAfterT, // 20
    "u": YunmusAfterU, // 19
    "v": YunmusAfterV, // 20
    "w": YunmusAfterW, // 9
    "x": YunmusAfterX, // 15
    "y": YunmusAfterY, // 17
    "z": YunmusAfterZ // 17
]

/// The dictionary from ZiranmaShengmu to the maximum length of following Yunmus
let MaxYunmuLength = [
    "a": 2,
    "b": 3,
    "c": 3,
    "d": 3,
    "e": 2,
    "f": 3,
    "g": 4,
    "h": 4,
    "i": 4,
    "j": 4,
    "k": 4,
    "l": 4,
    "m": 3,
    "n": 4,
    "o": 1,
    "p": 3,
    "q": 4,
    "r": 3,
    "s": 3,
    "t": 3,
    "u": 4,
    "v": 4,
    "w": 3,
    "x": 4,
    "y": 3,
    "z": 3
]

/// The dictionary from ZiranmaShengmu to the most common length of following Yunmus (the length happens most)
let CommonYunmuLength = [
    "a": 1,
    "b": 2,
    "c": 2,
    "d": 2,
    "e": 1,
    "f": 2,
    "g": 2,
    "h": 2,
    "i": 2,
    "j": 2,
    "k": 2,
    "l": 2,
    "m": 2,
    "n": 2,
    "o": 0,
    "p": 2,
    "q": 2,
    "r": 2,
    "s": 2,
    "t": 2,
    "u": 2,
    "v": 2,
    "w": 2,
    "x": 2,
    "y": 2,
    "z": 2
]


func getShengmuString(from formalizedString: String) -> String {
    
    let length = formalizedString.getReadingLength()
    var returnStr = ""
    for var index = 0; index < length; index+=3 {
        returnStr += String(Array(formalizedString)[index])
    }
    
    return returnStr
}

func getShuangpinString(from formalizedQuanpinString: String) -> String {
    
    let length = formalizedQuanpinString.getReadingLength()
    var strComponents = formalizedQuanpinString.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    var retComponents = strComponents.map({(x: String) -> String in return Shuangpin[x] ?? x})
    let retString = " ".join(retComponents)
    
    return retString
}
