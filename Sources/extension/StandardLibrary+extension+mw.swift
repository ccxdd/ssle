//
//  StandardLibrary+extension+mw.swift
//  StandardLibraryExtension
//
//  Created by ccxdd on 2016/10/27.
//  Copyright © 2016年 ccxdd. All rights reserved.
//

#if canImport(UIKit)
import UIKit
#else
import Foundation
#endif
import CryptoSwift

public extension String {
    
    #if os(iOS)
    public var image: UIImage? {
        return UIImage(named:self)
    }
    #endif
    
    public var isEmail: Bool {
        return matchRegular("^([a-zA-Z0-9_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,6})$")
    }
    
    public var isMobile: Bool {
        return (hasPrefix("1") && isInt && count == 11)
    }
    
    public var isInt: Bool {
        return Int(self) != nil
    }
    
    public var isDecimal: Bool {
        return Double(self) != nil
    }
    
    public var isABC: Bool {
        guard isEmpty == false else { return false }
        let list = "abcdefghijklmnopqrstuvwxyz".uppercased()
        return filter { !list.contains($0) }.isEmpty
    }
    
    public var isLowABC: Bool {
        guard isEmpty == false else { return false }
        let list = "abcdefghijklmnopqrstuvwxyz"
        return filter { !list.contains($0) }.isEmpty
    }
    
    public var isMixABC: Bool {
        guard isEmpty == false else { return false }
        let list = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return filter { !list.contains($0) }.isEmpty
    }
    
    public var isSymbol: Bool {
        guard !isEmpty else { return false }
        let list = "~`!@#$%^&*()_=+-.>,<|{}[]/?';:\"\\"
        return filter { !list.contains($0.description) }.isEmpty
    }
    
    public var url: URL? {
        guard let url = URL(string: self) else {
            guard let encode = self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                return nil
            }
            return URL(string: encode)
        }
        return url
    }
    
    public var urlRequest: URLRequest? {
        if let url = url {
            return URLRequest(url: url)
        } else {
            return nil
        }
    }
    
    public var decimalNum: Int {
        let dotArr = components(separatedBy: ".")
        guard dotArr.count < 3 else { return 0 }
        return dotArr.at(1)?.count ?? 0
    }
    
    public var hexToInt: Int? {
        let trimPrefix = replacingOccurrences(of: "0x", with: "")
        return Int(trimPrefix, radix: 16)
    }
    
    #if os(iOS)
    public func imageView(contentMode: UIView.ContentMode = .scaleAspectFit) -> UIImageView? {
        let imageView = UIImageView(image: self.image)
        imageView.contentMode = .scaleAspectFit
        return UIImageView(image: self.image)
    }
    #endif
    
    public func pinYin(_ blank: Bool = false) -> String {
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
    
    public func hexToData() -> Data {
        return Data(hex: self)
    }
    
    public var hexString: String {
        return self.data(using: .utf8)?.hex() ?? ""
    }
    
    public var mutableStr: NSMutableString {
        return NSMutableString(string: self)
    }
    
    public var attrStr: NSMutableAttributedString {
        return NSMutableAttributedString(string: self)
    }
    
    public func prefix(_ str: String?) -> String {
        guard let text = str else { return self }
        return text + self
    }
    
    public func suffix(_ str: String?) -> String {
        guard let text = str else { return self }
        return self + text
    }
    
    public func find(start: String, ends: [String]) -> (result: String, range: NSRange, content: String) {
        let source = self as NSString
        let startRange = source.range(of: start)
        let zero = ("", NSMakeRange(0, 0), "")
        guard startRange.length > 0 else { return zero }
        let endSource = source.substring(from: startRange.location) as NSString
        for s in ends {
            let endRange = endSource.range(of: s)
            if startRange.length != NSNotFound && endRange.location != NSNotFound {
                let newRange = NSUnionRange(startRange, NSRange(location: startRange.location + endRange.location, length: endRange.length))
                let r = source.substring(with: newRange)
                let c = r.replacingOccurrences(of: start, with: "").replacingOccurrences(of: s, with: "")
                return (r, newRange, c)
            }
        }
        return zero
    }
    
    public func subTo(_ idx: Int?) -> String? {
        guard let i = idx, i <= count, i >= 0 else { return nil }
        let arr = self[..<index(startIndex, offsetBy: i)]
        return String(arr)
    }
    
    public func subFrom(_ idx: Int?) -> String? {
        guard let i = idx, i <= count, i >= 0 else { return nil }
        let arr = self[index(startIndex, offsetBy: i)...]
        return String(arr)
    }

    /// to: 当前位置不包含本身,要包含+1
    public func sub(from: Int?, to: Int?) -> String? {
        guard let f = from, let t = to, f <= count , t <= count, f >= 0, t >= 0 else { return nil }
        let range: Range<String.Index> = index(startIndex, offsetBy: f) ..< index(startIndex, offsetBy: t)
        return String(self[range])
    }
    
    public func deleteLast(_ len: Int? = 0) -> String? {
        guard let l = len, l <= count else { return nil }
        let arr = self[..<index(endIndex, offsetBy: -l)]
        return String(arr)
    }
    
    public func mask(_ target: String?, symbol: String?) -> String? {
        guard let t = target, let s = symbol else { return nil }
        return replacingOccurrences(of: t, with: s.repetitions(t.count))
    }
    
    public func clearHtmlTag() -> String {
        var result = self
        while result.contains("<") {
            let tag = result.find(start: "<", ends: [">"])
            if tag.range.length > 0 {
                result = result.replacingOccurrences(of: tag.result, with: "")
            }
        }
        return result
    }
    
    public func allRange() -> NSRange {
        return NSMakeRange(0, count)
    }
    
    public var tI: Int {
        return Int(self) ?? 0
    }
    
    public var tF: Float {
        return Float(self) ?? 0
    }
    
    public var tD: Double {
        return Double(self) ?? 0
    }
    
    public var tCGF: CGFloat {
        return tD.tCGF
    }
    
    public var f2I: Int {
        let str = map { $0.description }.filter { "-1234567890".contains($0) }.joined()
        return str.tI
    }
    
    public var f2F: Float {
        let str = map { $0.description }.filter { "-1234567890.".contains($0) }.joined()
        return str.tF
    }
    
    public var f2D: Double {
        let str = map { $0.description }.filter { "-1234567890.".contains($0) }.joined()
        return str.tD
    }
    
    public func repetitions(_ count: Int) -> String {
        let arr: [String] = Array(repeating: self, count: count)
        return arr.joined()
    }
    
    public func dateFormat(_ frm: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: self)
        return date != nil ? date?.format(frm) : nil
    }
    
    static public func random(lenght: Int) -> String {
        let template = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
        var result = ""
        for _ in 0..<lenght {
            let s = Int.random(in: 0 ..< template.count)
            result += template.sub(from: s, to: s + 1)!
        }
        return result
    }
    
    /// 只做MD5 32位提取
    public var md5_16: String {
        guard self.count == 32, let s = sub(from: 8, to: 24) else { return "" }
        return s
    }
    
    public func UTC2NowTimeZone() -> String? {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
        return df.date(from: self + "+0000")?.tS
    }
    
    public func save(paths: String..., dir: FileManager.SearchPathDirectory = .libraryDirectory, overwrite: Bool = false) -> Bool {
        var fileUrl = FileManager.default.urls(for: dir, in: .userDomainMask).first!
        var folder = fileUrl
        for s in paths.dropLast() {
            folder.appendPathComponent(s)
        }
        for s in paths {
            fileUrl.appendPathComponent(s)
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
        let fileExist = FileManager.default.fileExists(atPath: fileUrl.path)
        switch (fileExist, overwrite) {
        case (true, true):
            do {
                try write(to: fileUrl, atomically: true, encoding: .utf8)
                return true
            } catch {
                print(error)
                return false
            }
        case (false, _):
            return FileManager.default.createFile(atPath: fileUrl.path, contents: data(using: .utf8))
        case (true, false):
            return false
        }
    }
    
    static public func load(paths: String..., dir: FileManager.SearchPathDirectory = .libraryDirectory) -> String? {
        var dirUrl = FileManager.default.urls(for: dir, in: .userDomainMask).first!
        for s in paths {
            dirUrl.appendPathComponent(s)
        }
        return try? String(contentsOf: dirUrl, encoding: .utf8)
    }
    
    public func fill0(len: Int, left: Bool = true) -> String {
        var result = self
        guard len > count else { return self }
        if left {
            result.insert(contentsOf: "0".repetitions(len - count), at: startIndex)
        } else {
            result.append("0".repetitions(len - count))
        }
        return result
    }
    
    public var passwordStrength: (desc: String, level: Int) {
        var abcBig = false
        var abcLow = false
        var sym = false
        var num = false
        let len = count
        if len == 0 {
            return ("Password field empty", 0)
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
            return ("Weak", 2)
        case 2 where len >= 8:
            return ("Average", 3)
        case 3 where len >= 8:
            return ("Strong", 4)
        case 4 where len >= 8:
            return ("Very Strong", 5)
        default: return ("Very Weak", 1)
        }
    }
    
    public func matchRegular(_ pattern: String) -> Bool {
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        if let matches = regex?.matches(in: self, options: [], range: NSMakeRange(0, count)) {
            return matches.count > 0
        } else {
            return false
        }
    }
    
    public func radix(_ r: Int) -> Int {
        return Int(self, radix: r) ?? 0
    }
}

public extension Substring {
    public var tS: String {
        return String(self)
    }
}

public extension NSAttributedString {
    public var mutableAttrStr: NSMutableAttributedString {
        return NSMutableAttributedString(attributedString: self)
    }
}

public extension Data {
    public func hex() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
    
    public var tS: String? {
        return String(data: self, encoding: .utf8)
    }
    
    public func save(paths: String..., dir: FileManager.SearchPathDirectory = .libraryDirectory, overwrite: Bool = false) -> Bool {
        var fileUrl = FileManager.default.urls(for: dir, in: .userDomainMask).first!
        var folder = fileUrl
        for s in paths.dropLast() {
            folder.appendPathComponent(s)
        }
        for s in paths {
            fileUrl.appendPathComponent(s)
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
        let fileExist = FileManager.default.fileExists(atPath: fileUrl.path)
        switch (fileExist, overwrite) {
        case (true, true):
            do {
                try write(to: fileUrl)
                return true
            } catch {
                print(error)
                return false
            }
        case (false, _):
            return FileManager.default.createFile(atPath: fileUrl.path, contents: self)
        case (true, false):
            return false
        }
    }
    
    public static func load(paths: String..., dir: FileManager.SearchPathDirectory = .libraryDirectory) -> Data? {
        var dirUrl = FileManager.default.urls(for: dir, in: .userDomainMask).first!
        for s in paths {
            dirUrl.appendPathComponent(s)
        }
        return try? Data(contentsOf: dirUrl)
    }
    
    public static func random(len: Int) -> Data {
        var result = ""
        for _ in 0 ..< len * 2 {
            result += String(Int.random(in: 0...15), radix: 16)
        }
        return Data(hex: result)
    }
    
    public func tString(encoding: String.Encoding = .utf8) -> String? {
        return String(data: self, encoding: encoding)
    }
}

public extension Double {
    
    public var tS: String {
        let str = description
        if str.contains("e") {
            return decimal(digits: 8).string
        }
        return str
    }
    
    public var decimalNum: Int {
        return tS.components(separatedBy: ".").at(1)?.count ?? 0
    }
    
    /// 设置 numberStyle 会有","分隔符
    public func decimal(digits: Int, roundingMode: NumberFormatter.RoundingMode = .floor, separator: String = ",") -> (num: Double, string: String, fmtString: String) {
        let numFmt = NumberFormatter()
        numFmt.numberStyle = .decimal
        numFmt.maximumFractionDigits = digits
        numFmt.roundingMode = roundingMode
        numFmt.groupingSeparator = separator
        let fmtStr = numFmt.string(from: NSNumber(value: self))!
        let str = fmtStr.replacingOccurrences(of: separator, with: "")
        return (str.tD, str, fmtStr)
    }
    
    public var tI: Int {
        return Int(self)
    }
    
    public var tCGF: CGFloat {
        return CGFloat(self)
    }
    
    public var tF: Float {
        return Float(self)
    }
    
    public var tFloor: Double {
        return floor(self)
    }
    
    public var tCeil: Double {
        return ceil(self)
    }
    
    public func random(down: Double = 0, equal: Bool = false) -> Double {
        if equal {
            return Double.random(in: down ... self)
        } else {
            return Double.random(in: down ..< self)
        }
    }
}

public extension Float {
    public func random(down: Float = 0, equal: Bool = false) -> Float {
        if equal {
            return Float.random(in: down ... self)
        } else {
            return Float.random(in: down ..< self)
        }
    }
    
    public var tI: Int {
        return Int(self)
    }
    
    public var tCGF: CGFloat {
        return CGFloat(self)
    }
    
    public var tFloor: Float {
        return floor(self)
    }
    
    public var tCeil: Float {
        return ceil(self)
    }
    
    public var tD: Double {
        return Double(self)
    }
    
    public var tS: String {
        let str = description
        if str.contains("e") {
            return tD.decimal(digits: 6).string
        }
        return str
    }
}

public extension TimeInterval {
    public var string: String {
        return String(Int(self))
    }
}

public extension Date {
    public var tS: String {
        return format("yyyy-MM-dd HH:mm:ss")
    }
    
    static var UTC: Date {
        let tz: TimeZone = TimeZone.current
        let secs = tz.secondsFromGMT() > 0 ? -tz.secondsFromGMT() : tz.secondsFromGMT()
        return Date(timeInterval: TimeInterval(secs), since: Date())
    }
    
    public func format(_ f: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = f
        let str = dateFormatter.string(from: self)
        return str
    }
}

public extension Bool {
    public func then(_ closure: () -> Void) {
        if self { closure() }
    }
    
    public func noEqual(_ closure : () -> Void) {
        if self == false { closure() }
    }
}

public extension CGFloat {
    public static var pi360: CGFloat {
        return CGFloat.pi * 2
    }
    
    public static var pi270: CGFloat {
        return CGFloat.pi * 1.5
    }
    
    public static var pi90: CGFloat {
        return CGFloat.pi / 2
    }
    
    public static var pi45: CGFloat {
        return CGFloat.pi / 4
    }
    
    public static var pi30: CGFloat {
        return CGFloat.pi / 6
    }
    
    public static var pi15: CGFloat {
        return CGFloat.pi / 12
    }
    
    public var tI: Int {
        return Int(self)
    }
    
    public var tFloor: CGFloat {
        return floor(self)
    }
    
    public var tCeil: CGFloat {
        return ceil(self)
    }
    
    public var tF: Float {
        return Float(self)
    }
    
    public var tD: Double {
        return Double(self)
    }
    
    public var tS: String {
        return description
    }
    
    public func decimal(digits: Int, roundingMode: NumberFormatter.RoundingMode = .floor, separator: String = ",") -> (num: CGFloat, string: String, fmtString: String) {
        let result = tD.decimal(digits: digits, roundingMode: roundingMode, separator: separator)
        return (result.num.tCGF, result.string, result.fmtString)
    }
    
    public func random(down: CGFloat = 0, equal: Bool = false) -> CGFloat {
        if equal {
            return CGFloat.random(in: down ... self)
        } else {
            return CGFloat.random(in: down ..< self)
        }
    }
    
    public func relative(v: CGFloat) -> CGFloat {
        guard v > 0 else { return 0 }
        return (1 - self/v) * v
    }
    
    public func percent(v: CGFloat) -> CGFloat {
        return self / v * 100
    }
    
    public func pointX(_ x: CGFloat = 0) -> CGPoint {
        return CGPoint(x: x, y: self)
    }
    
    public func pointY(_ y: CGFloat = 0) -> CGPoint {
        return CGPoint(x: self, y: y)
    }
    
    public func tPi() -> CGFloat {
        return self / 180 * CGFloat.pi
    }
}

public extension CGPoint {
    /// 0度从东面开始算
    public func tArcPoint(r: CGFloat, pi: CGFloat) -> CGPoint {
        let xx = x + cos(pi) * r
        let yy = y + sin(pi) * r
        return CGPoint(x: xx, y: yy)
    }
}

public extension Int {
    public var tCGF: CGFloat {
        return CGFloat(self)
    }
    
    public var tD: Double {
        return Double(self)
    }
    
    public var tF: Float {
        return Float(self)
    }
    
    public var tS: String {
        return description
    }
    
    public var tUnicodeScalar: UnicodeScalar? {
        return UnicodeScalar(self)
    }
    
    public func random(down: Int = 0, equal: Bool = false) -> Int {
        if equal {
            return Int.random(in: down ... self)
        } else {
            return Int.random(in: down ..< self)
        }
    }
    
    #if os(iOS)
    public func row(section: Int = 0) -> IndexPath {
        return IndexPath(row: self, section: section)
    }
    
    public func section(row: Int = 0) -> IndexPath {
        return IndexPath(row: row, section: self)
    }
    #endif
    
    public func pointX(_ x: CGFloat = 0) -> CGPoint {
        return CGPoint(x: x, y: tCGF)
    }
    
    public func pointY(_ y: CGFloat = 0) -> CGPoint {
        return CGPoint(x: tCGF, y: y)
    }
    
    public func tPi() -> CGFloat {
        return self.tCGF / 180 * CGFloat.pi
    }
    
    public func radix(_ r: Int, len: Int, left: Bool = true) -> String {
        var result = String(self, radix: r)
        result = result.count % 2 == 0 ? result : "0" + result
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
