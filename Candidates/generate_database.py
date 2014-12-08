import io
import sqlite3

# The dictionary of StandardizedShuangpin: Quanpin
Quanpin = {
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

    "lO": "lo", # update database with lo
    "om": "m",
    "on": "n",
    "hm": "hm",
    "nG": "ng"  # update database with ng
}

Shuangpin = dict((v,k) for k, v in Quanpin.iteritems())

print "!!! Source txt file should be utf-8 encoding !!!"

file = io.open("rawdict_utf8_65105_freq.txt", 'r', encoding='utf-8')
lines = file.readlines()

frequenciesList = []
frequenciesSet = set()

for line in lines:
  info = line.split()
  frequency = info[1]
  frequenciesList.append(frequency)
  frequenciesSet.add(frequency)

sortedFrequenciesList = sorted(list(frequenciesSet), key=float)
sortedFrequenciesDict = {}

for index, item in enumerate(sortedFrequenciesList):
  sortedFrequenciesDict[item] = index

records = []

count = 0
for line in lines:
  info = line.split()
  candidate = info[0]
  frequency = sortedFrequenciesDict[info[1]]
  unusual = bool(int(info[2]))
  quanpinArray = info[3:]
  if quanpinArray[0] == "hng":
    continue
  length = len(candidate)
  shuangpinArray = map(lambda x: Shuangpin[x], quanpinArray)
  shengmuArray = map(lambda x: x[0], shuangpinArray)
  quanpinString = ' '.join(quanpinArray)
  shuangpinString = ' '.join(shuangpinArray)
  shengmuString = ''.join(shengmuArray)
  candidateType = 1
  record = (candidate, shuangpinString, shengmuString, length, frequency, quanpinString, candidateType)
  records.append(record)
  count += 1

print(str(count) + " records have added into database")

file = io.open("english_word_list.txt", 'r', encoding='utf-8')
lines = file.readlines()

count = 0
for line in lines:
  word = line.rstrip('\n')
  candidate = word
  shuangpinString = word.lower()
  shengmuString = word[0].lower()
  length = len(word)
  frequency = 0
  quanpinString = word.lower()
  candidateType = 2
  record = (candidate, shuangpinString, shengmuString, length, frequency, quanpinString, candidateType)
  records.append(record)
  count += 1

print(str(count) + " records have added into database")

file = io.open("extra_candidates_utf8.txt", 'r', encoding='utf-8')
lines = file.readlines()

count = 0
for line in lines:
  record = tuple(line.split(', '))
  records.append(record)
  count += 1

print(str(count) + " records have added into database")

conn = sqlite3.connect('candidates.sqlite')
c = conn.cursor()

c.execute('''CREATE TABLE candidates
             (candidate text,
              shuangpin text,
              shengmu text,
              length integer,
              frequency integer,
              quanpin text,
              candidate_type integer,
              primary key (candidate, shuangpin))''')

c.executemany('''INSERT
                 INTO candidates (candidate,
                                  shuangpin,
                                  shengmu,
                                  length,
                                  frequency,
                                  quanpin,
                                  candidate_type)
                 VALUES (?, ?, ?, ?, ?, ?, ?)''', records)

c.execute('''CREATE INDEX idx_shengmu on candidates(shengmu)''')

conn.commit()
conn.close()
