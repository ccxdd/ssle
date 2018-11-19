//
//  StandardLibrary+extension+mw.swift
//  StandardLibraryExtension
//
//  Created by ccxdd on 2016/10/27.
//  Copyright © 2016年 ccxdd. All rights reserved.
//

import UIKit
import CryptoSwift

extension String {
    var image: UIImage? {
        return UIImage(named:self)
    }
    
    var isEmail: Bool {
        return (contains(".") && contains("@") && !hasPrefix(".") && !hasPrefix("@") && !hasSuffix(".") && !hasSuffix("@") && !contains("@@") && !contains("..") && !contains(" ") && !hasPrefix(" ") && !hasSuffix(" "))
    }
    
    var isMobile: Bool {
        return (hasPrefix("1") && isInt && count == 11)
    }
    
    var isInt: Bool {
        return Int(self) != nil
    }
    
    var isDecimal: Bool {
        return Double(self) != nil
    }
    
    var isABC: Bool {
        guard isEmpty == false else { return false }
        let list = "abcdefghijklmnopqrstuvwxyz".uppercased()
        return filter { !list.contains($0) }.isEmpty
    }
    
    var isLowABC: Bool {
        guard isEmpty == false else { return false }
        let list = "abcdefghijklmnopqrstuvwxyz"
        return filter { !list.contains($0) }.isEmpty
    }
    
    var isMixABC: Bool {
        guard isEmpty == false else { return false }
        let list = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return filter { !list.contains($0) }.isEmpty
    }
    
    var isSymbol: Bool {
        guard !isEmpty else { return false }
        let list = "~`!@#$%^&*()_=+-.>,<|{}[]/?';:\"\\"
        return filter { !list.contains($0.description) }.isEmpty
    }
    
    var url: URL? {
        guard let url = URL(string: self) else {
            guard let encode = self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                return nil
            }
            return URL(string: encode)
        }
        return url
    }
    
    var urlRequest: URLRequest? {
        if let url = url {
            return URLRequest(url: url)
        } else {
            return nil
        }
    }
    
    var decimalNum: Int? {
        let dotArr = components(separatedBy: ".")
        guard dotArr.count < 3 else { return nil }
        return dotArr.at(1)?.count
    }
    
    var hexToInt: Int? {
        return Int(self, radix: 16)
    }
    
    func imageView(contentMode: UIView.ContentMode = .scaleAspectFit) -> UIImageView? {
        let imageView = UIImageView(image: self.image)
        imageView.contentMode = .scaleAspectFit
        return UIImageView(image: self.image)
    }
    
    func pinYin(_ blank: Bool = false) -> String {
        let mstr = NSMutableString.init(string: self) as CFMutableString
        if CFStringTransform(mstr, nil, kCFStringTransformMandarinLatin, false) {
            if CFStringTransform(mstr, nil, kCFStringTransformStripDiacritics, false) {
                if blank {
                    return mstr as String
                } else {
                    return (mstr as String).components(separatedBy: " ").joined()
                }
            }
        }
        return self
    }
    
    func hexToData() -> Data {
        return Data(hex: self)
    }
    
    var hexString: String {
        return self.data(using: .utf8)?.hex() ?? ""
    }
    
    var mutableStr: NSMutableString {
        return NSMutableString(string: self)
    }
    
    var attrStr: NSMutableAttributedString {
        return NSMutableAttributedString(string: self)
    }
    
    func prefix(_ str: String?) -> String {
        guard let text = str else { return self }
        return text + self
    }
    
    func suffix(_ str: String?) -> String {
        guard let text = str else { return self }
        return self + text
    }
    
    func find(start: String, ends: [String]) -> (result: String, range: NSRange, content: String) {
        let source = self as NSString
        let startRange = source.range(of: start)
        for s in ends {
            let endRange = source.range(of: s)
            if startRange.length != NSNotFound && endRange.location != NSNotFound {
                let newRange = NSUnionRange(startRange, endRange)
                let r = source.substring(with: newRange) as String
                let c = r.replacingOccurrences(of: start, with: "").replacingOccurrences(of: s, with: "")
                return (r, newRange, c)
            }
        }
        return ("", NSMakeRange(0, 0), "")
    }
    
    func subTo(_ idx: Int?) -> String? {
        guard let i = idx, i <= count, i >= 0 else { return nil }
        let arr = self[..<index(startIndex, offsetBy: i)]
        return String(arr)
    }
    
    func subFrom(_ idx: Int?) -> String? {
        guard let i = idx, i <= count, i >= 0 else { return nil }
        let arr = self[index(startIndex, offsetBy: i)...]
        return String(arr)
    }
    
    func sub(from: Int?, to: Int?) -> String? {
        guard let f = from, let t = to, f <= count , t <= count, f >= 0, t >= 0 else { return nil }
        let range: Range<String.Index> = index(startIndex, offsetBy: f) ..< index(startIndex, offsetBy: t)
        return String(self[range])
    }
    
    func deleteLast(_ len: Int? = 0) -> String? {
        guard let l = len, l <= count else { return nil }
        let arr = self[..<index(endIndex, offsetBy: -l)]
        return String(arr)
    }
    
    func mask(_ target: String?, symbol: String?) -> String? {
        guard let t = target, let s = symbol else { return nil }
        return replacingOccurrences(of: t, with: s.repetitions(t.count))
    }
    
    func clearHtmlTag() -> String {
        var result = self
        while result.contains("<") {
            let tag = result.find(start: "<", ends: [">"])
            if tag.range.length > 0 {
                result = result.replacingOccurrences(of: tag.result, with: "")
            }
        }
        return result
    }
    
    func allRange() -> NSRange {
        return NSMakeRange(0, count)
    }
    
    var tI: Int {
        return Int(self) ?? 0
    }
    
    var tF: Float {
        return Float(self) ?? 0
    }
    
    var tD: Double {
        return Double(self) ?? 0
    }
    
    var tCGF: CGFloat {
        return tD.tCGF
    }
    
    var f2I: Int {
        let str = map { $0.description }.filter { "-1234567890".contains($0) }.joined()
        return str.tI
    }
    
    var f2F: Float {
        let str = map { $0.description }.filter { "-1234567890.".contains($0) }.joined()
        return str.tF
    }
    
    var f2D: Double {
        let str = map { $0.description }.filter { "-1234567890.".contains($0) }.joined()
        return str.tD
    }
    
    func repetitions(_ count: Int) -> String {
        let arr: [String] = Array(repeating: self, count: count)
        return arr.joined()
    }
    
    func dateFormat(_ frm: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: self)
        return date != nil ? date?.format(frm) : nil
    }
    
    static func random(lenght: Int) -> String {
        let template = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
        var result = ""
        for _ in 0..<lenght {
            let s = Int.random(up: template.count)
            result += template.sub(from: s, to: s + 1)!
        }
        return result
    }
    
    /// 只做MD5 32位提取
    var md5_16: String {
        guard self.count == 32, let s = sub(from: 8, to: 24) else { return "" }
        return s
    }
    
    func UTC2NowTimeZone() -> String? {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
        return df.date(from: self + "+0000")?.tS
    }
    
    func save(paths: String..., dir: FileManager.SearchPathDirectory = .libraryDirectory) -> Bool {
        var dirUrl = FileManager.default.urls(for: dir, in: .userDomainMask).first!
        var folder = dirUrl
        for s in paths.dropLast() {
            folder.appendPathComponent(s)
        }
        for s in paths {
            dirUrl.appendPathComponent(s)
        }
        var isDir: ObjCBool = true
        let createDirClosure = {
            do {
                try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)
            } catch let err {
                print(err.localizedDescription)
            }
        }
        if FileManager.default.fileExists(atPath: folder.path, isDirectory: &isDir) {
            if isDir.boolValue == false {
                createDirClosure()
            }
        } else {
            createDirClosure()
        }
        do {
            try write(to: dirUrl, atomically: true, encoding: .utf8)
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    static func load(paths: String..., dir: FileManager.SearchPathDirectory = .libraryDirectory) -> String? {
        var dirUrl = FileManager.default.urls(for: dir, in: .userDomainMask).first!
        for s in paths {
            dirUrl.appendPathComponent(s)
        }
        return try? String(contentsOf: dirUrl, encoding: .utf8)
    }
    
    func fill0(len: Int, left: Bool = true) -> String {
        var result = self
        guard len > count else { return self }
        if left {
            result.insert(contentsOf: "0".repetitions(len - count), at: startIndex)
        } else {
            result.append("0".repetitions(len - count))
        }
        return result
    }
    
    var passwordStrength: String {
        var abcBig = false
        var abcLow = false
        var sym = false
        var num = false
        let len = count
        if len == 0 {
            return "The password is empty."
        }
        for i in self {
            if !abcBig {
                abcBig = i.description.isABC
            }
            if !abcLow {
                abcLow = i.description.isLowABC
            }
            if !sym {
                sym = i.description.isSymbol
            }
            if !num {
                num = i.description.isInt
            }
        }
        let conditionCount = [abcLow, abcBig, num, sym].filter({ $0 == true }).count
        switch conditionCount {
        case 1 where len >= 8:
            return "The password is weak."
        case 2 where len >= 8:
            return "The password is not bad."
        case 3 where len >= 8:
            return "The password is strong."
        case 4 where len >= 8:
            return "The password is very strong."
        default: return "The password is very weak."
        }
    }
}

extension NSAttributedString {
    var mutableAttrStr: NSMutableAttributedString {
        return NSMutableAttributedString(attributedString: self)
    }
}

extension Data {
    func hex() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
    
    var tS: String? {
        return String(data: self, encoding: .utf8)
    }
    
    func save(paths: String..., dir: FileManager.SearchPathDirectory = .libraryDirectory) -> Bool {
        var dirUrl = FileManager.default.urls(for: dir, in: .userDomainMask).first!
        var folder = dirUrl
        for s in paths.dropLast() {
            folder.appendPathComponent(s)
        }
        for s in paths {
            dirUrl.appendPathComponent(s)
        }
        var isDir: ObjCBool = true
        let createDirClosure = {
            do {
                try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)
            } catch let err {
                print(err.localizedDescription)
            }
        }
        if FileManager.default.fileExists(atPath: folder.path, isDirectory: &isDir) {
            if isDir.boolValue == false {
                createDirClosure()
            }
        } else {
            createDirClosure()
        }
        do {
            try write(to: dirUrl)
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    static func load(paths: String..., dir: FileManager.SearchPathDirectory = .libraryDirectory) -> Data? {
        var dirUrl = FileManager.default.urls(for: dir, in: .userDomainMask).first!
        for s in paths {
            dirUrl.appendPathComponent(s)
        }
        return try? Data(contentsOf: dirUrl)
    }
}

extension Double {
    
    enum DecimalType {
        case floor, ceil, round
    }
    
    var tS: String {
        return description
    }
    
    var decimalNum: Int {
        return tS.components(separatedBy: ".").at(1)?.count ?? 0
    }
    
    func decimal(_ count: Int = 0, type: DecimalType = .round) -> Double {
        guard count > 0 else { return tI.tD }
        let divide: Double = pow(10, Double(count))
        let result: Double
        switch type {
        case .floor:
            result = floor(divide * self) / divide
        case .ceil:
            result = ceil(divide * self) / divide
        case .round:
            result = Darwin.round(divide * self) / divide
        }
        return result
    }
    
    var tI: Int {
        return Int(self)
    }
    
    var tCGF: CGFloat {
        return CGFloat(self)
    }
    
    var tF: Float {
        return Float(self)
    }
    
    var tFloor: Double {
        return floor(self)
    }
    
    var tCeil: Double {
        return ceil(self)
    }
}

extension Float {
    func format(_ f: String) -> String {
        return String(format: "%\(f)f", self)
    }
    
    func random() -> Float {
        var result: Float = 0.0
        let denominator = self.tI.tF
        var member = self - denominator
        result += denominator.tI.random().tF
        member *= 10000
        member = member.tI.random().tF
        member /= 10000
        result += member
        return result
    }
    
    var tI: Int {
        return Int(self)
    }
    
    var tCGF: CGFloat {
        return CGFloat(self)
    }
    
    var tFloor: Float {
        return floor(self)
    }
    
    var tCeil: Float {
        return ceil(self)
    }
    
    var tD: Double {
        return Double(self)
    }
    
    var tS: String {
        let str = description
        if str.contains("e") {
            let numFmt = NumberFormatter()
            numFmt.numberStyle = .decimal
            return numFmt.string(from: NSNumber(value: self)) ?? str
        }
        return str
    }
}

extension TimeInterval {
    var string: String {
        return String(Int(self))
    }
}

extension Date {
    var tS: String {
        return format("yyyy-MM-dd HH:mm:ss")
    }
    
    static var UTC: Date {
        let tz: TimeZone = TimeZone.current
        let secs = tz.secondsFromGMT() > 0 ? -tz.secondsFromGMT() : tz.secondsFromGMT()
        return Date(timeInterval: TimeInterval(secs), since: Date())
    }
    
    func format(_ f: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = f
        let str = dateFormatter.string(from: self)
        return str
    }
}

extension Bool {
    func then(_ closure: () -> Void) {
        if self { closure() }
    }
    
    func noEqual(_ closure : () -> Void) {
        if self == false { closure() }
    }
}

extension CGFloat {
    
    var tI: Int {
        return Int(self)
    }
    
    var tFloor: CGFloat {
        return floor(self)
    }
    
    var tCeil: CGFloat {
        return ceil(self)
    }
    
    var tF: Float {
        return Float(self)
    }
    
    var tD: Double {
        return Double(self)
    }
    
    var tS: String {
        return description
    }
    
    func random() -> CGFloat {
        return tF.random().tCGF
    }
    
    func relative(v: CGFloat) -> CGFloat {
        guard v > 0 else { return 0 }
        return (1 - self/v) * v
    }
    
    func percent(v: CGFloat) -> CGFloat {
        return self / v * 100
    }
    
    func pointX(_ x: CGFloat = 0) -> CGPoint {
        return CGPoint(x: x, y: self)
    }
    
    func pointY(_ y: CGFloat = 0) -> CGPoint {
        return CGPoint(x: self, y: y)
    }
    
    func tPi() -> CGFloat {
        return self / 180 * CGFloat.pi
    }
}

extension CGPoint {
    /// 0度从东面开始算
    func tArcPoint(r: CGFloat, pi: CGFloat) -> CGPoint {
        let xx = x + cos(pi) * r
        let yy = y + sin(pi) * r
        return CGPoint(x: xx, y: yy)
    }
}

extension Int {
    
    var tCGF: CGFloat {
        return CGFloat(self)
    }
    
    var tD: Double {
        return Double(self)
    }
    
    var tF: Float {
        return Float(self)
    }
    
    var tS: String {
        return description
    }
    
    var tUnicodeScalar: UnicodeScalar? {
        return UnicodeScalar(self)
    }
    
    static func random(up: Int, down: Int = 0, equal: Bool = false) -> Int {
        return Swift.max(Int(arc4random_uniform(UInt32(up + (equal == true ? 1 : 0)))), down)
    }
    
    func random(_ down: Int = 0) -> Int {
        return Int.random(up: self, down: down, equal: false)
    }
    
    func row(section: Int = 0) -> IndexPath {
        return IndexPath(row: self, section: section)
    }
    
    func section(row: Int = 0) -> IndexPath {
        return IndexPath(row: row, section: self)
    }
    
    func pointX(_ x: CGFloat = 0) -> CGPoint {
        return CGPoint(x: x, y: tCGF)
    }
    
    func pointY(_ y: CGFloat = 0) -> CGPoint {
        return CGPoint(x: tCGF, y: y)
    }
    
    func tPi() -> CGFloat {
        return self.tCGF / 180 * CGFloat.pi
    }
    
    func radix(_ r: Int, len: Int, left: Bool = true) -> String {
        var result = String(self, radix: r)
        let fillCount = len - result.count
        if fillCount > 0 {
            if left {
                result.insert(contentsOf: "0".repetitions(fillCount), at: result.startIndex)
            } else {
                result.append("0".repetitions(fillCount))
            }
        }
        return result
    }
}
