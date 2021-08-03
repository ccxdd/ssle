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

//MARK: String
public extension String {
    
    #if os(iOS)
    var image: UIImage? {
        return UIImage(named:self)
    }
    #endif
    
    var isEmail: Bool {
        return matchRegular("[\\w!#$%&'*+/=?^_`{|}~-]+(?:\\.[\\w!#$%&'*+/=?^_`{|}~-]+)*@(?:[\\w](?:[\\w-]*[\\w])?\\.)+[\\w](?:[\\w-]*[\\w])?")
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
    
    var decimalNum: Int {
        let dotArr = components(separatedBy: ".")
        guard dotArr.count < 3 else { return 0 }
        return dotArr.at(1)?.count ?? 0
    }
    
    var hexToInt: Int? {
        let trimPrefix = replacingOccurrences(of: "0x", with: "")
        return Int(trimPrefix, radix: 16)
    }
    
    #if os(iOS)
    func imageView(contentMode: UIView.ContentMode = .scaleAspectFit) -> UIImageView? {
        let imageView = UIImageView(image: self.image)
        imageView.contentMode = .scaleAspectFit
        return UIImageView(image: self.image)
    }
    #endif
    
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
    
    @discardableResult
    func prefix(_ str: String?) -> String {
        guard let text = str else { return self }
        return text + self
    }
    
    @discardableResult
    func suffix(_ str: String?) -> String {
        guard let text = str else { return self }
        return self + text
    }
    
    func find(start: String, ends: [String]) -> (result: String, range: NSRange, content: String) {
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
        if ends.count == 0 {
            let resultStr = endSource as String
            return (resultStr, NSMakeRange(startRange.location, resultStr.count), resultStr.replacingOccurrences(of: start, with: ""))
        }
        return zero
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

    /// to: 当前位置不包含本身,要包含+1
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
            let s = Int.random(in: 0 ..< template.count)
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
    
    func save(paths: String..., dir: FileManager.SearchPathDirectory = .libraryDirectory, overwrite: Bool = false) -> Bool {
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
    
    var passwordStrength: (desc: String, level: Int) {
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
    
    func matchRegular(_ pattern: String) -> Bool {
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        if let matches = regex?.matches(in: self, options: [], range: NSMakeRange(0, count)) {
            return matches.count > 0
        } else {
            return false
        }
    }
    
    func radix(_ r: Int) -> Int {
        return Int(self, radix: r) ?? 0
    }
}

//MARK: Substring
public extension Substring {
    var tS: String {
        return String(self)
    }
}

//MARK: NSAttributedString
public extension NSAttributedString {
    var mutableAttrStr: NSMutableAttributedString {
        return NSMutableAttributedString(attributedString: self)
    }
}

//MARK: Data
public extension Data {
    func hex() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
    
    var tS: String? {
        return String(data: self, encoding: .utf8)
    }
    
    func save(paths: String..., dir: FileManager.SearchPathDirectory = .libraryDirectory, overwrite: Bool = false) -> Bool {
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
    
    static func load(paths: String..., dir: FileManager.SearchPathDirectory = .libraryDirectory) -> Data? {
        var dirUrl = FileManager.default.urls(for: dir, in: .userDomainMask).first!
        for s in paths {
            dirUrl.appendPathComponent(s)
        }
        return try? Data(contentsOf: dirUrl)
    }
    
    static func random(len: Int) -> Data {
        var result = ""
        for _ in 0 ..< len * 2 {
            result += String(Int.random(in: 0...15), radix: 16)
        }
        return Data(hex: result)
    }
    
    func tString(encoding: String.Encoding = .utf8) -> String? {
        return String(data: self, encoding: encoding)
    }
}

//MARK: Double
public extension Double {
    
    var tS: String {
        let str = description
        if str.contains("e") {
            return decimal(digits: 8).string
        }
        return str
    }
    
    var decimalNum: Int {
        return tS.components(separatedBy: ".").at(1)?.count ?? 0
    }
    
    /// 设置 numberStyle 会有","分隔符
    func decimal(digits: Int, minDigits: Int = 0, roundingMode: NumberFormatter.RoundingMode = .floor, separator: String = ",") -> (num: Double, string: String, fmtString: String) {
        let numFmt = NumberFormatter()
        numFmt.numberStyle = .decimal
        numFmt.maximumFractionDigits = digits
        numFmt.minimumFractionDigits = minDigits
        numFmt.roundingMode = roundingMode
        numFmt.groupingSeparator = separator
        let fmtStr = numFmt.string(from: NSNumber(value: self))!
        let str = fmtStr.replacingOccurrences(of: separator, with: "")
        return (str.tD, str, fmtStr)
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
    
    func random(down: Double = 0, equal: Bool = false) -> Double {
        if equal {
            return Double.random(in: down ... self)
        } else {
            return Double.random(in: down ..< self)
        }
    }
}

//MARK: Float
public extension Float {
    func random(down: Float = 0, equal: Bool = false) -> Float {
        if equal {
            return Float.random(in: down ... self)
        } else {
            return Float.random(in: down ..< self)
        }
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
            return tD.decimal(digits: 6).string
        }
        return str
    }
}

//MARK: TimeInterval
public extension TimeInterval {
    var string: String {
        return String(Int(self))
    }
}

//MARK: Date
public extension Date {
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

//MARK: Bool
public extension Bool {
    func then(_ closure: () -> Void) {
        if self { closure() }
    }
    
    func noEqual(_ closure : () -> Void) {
        if self == false { closure() }
    }
}

//MARK: CGFloat
public extension CGFloat {
    static var pi360: CGFloat {
        return CGFloat.pi * 2
    }
    
    static var pi270: CGFloat {
        return CGFloat.pi * 1.5
    }
    
    static var pi90: CGFloat {
        return CGFloat.pi / 2
    }
    
    static var pi45: CGFloat {
        return CGFloat.pi / 4
    }
    
    static var pi30: CGFloat {
        return CGFloat.pi / 6
    }
    
    static var pi15: CGFloat {
        return CGFloat.pi / 12
    }
    
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
    
    func decimal(digits: Int, minDigits: Int = 0, roundingMode: NumberFormatter.RoundingMode = .floor, separator: String = ",") -> (num: CGFloat, string: String, fmtString: String) {
        let result = tD.decimal(digits: digits, minDigits: minDigits, roundingMode: roundingMode, separator: separator)
        return (result.num.tCGF, result.string, result.fmtString)
    }
    
    func random(down: CGFloat = 0, equal: Bool = false) -> CGFloat {
        if equal {
            return CGFloat.random(in: down ... self)
        } else {
            return CGFloat.random(in: down ..< self)
        }
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

//MARK: CGPoint
public extension CGPoint {
    /// 0度从东面开始算
    func tArcPoint(r: CGFloat, pi: CGFloat) -> CGPoint {
        let xx = x + cos(pi) * r
        let yy = y + sin(pi) * r
        return CGPoint(x: xx, y: yy)
    }
}

//MARK: Int
public extension Int {
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
    
    var tUInt8: UInt8 {
        return UInt8(self)
    }
    
    var tUInt: UInt {
        return UInt(self)
    }
    
    var tUnicodeScalar: UnicodeScalar? {
        return UnicodeScalar(self)
    }
    
    func random(down: Int = 0, equal: Bool = false) -> Int {
        if equal {
            return Int.random(in: down ... self)
        } else {
            return Int.random(in: down ..< self)
        }
    }
    
    #if os(iOS)
    func row(section: Int = 0) -> IndexPath {
        return IndexPath(row: self, section: section)
    }
    
    func section(row: Int = 0) -> IndexPath {
        return IndexPath(row: row, section: self)
    }
    #endif
    
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
        return tUInt.radix(r, len: len, left: left)
    }
}

//MARK: UInt8
public extension UInt8 {
    var tI: Int {
        return Int(self)
    }
}

//MARK: UInt
public extension UInt {
    var tI: Int {
        return Int(self)
    }
    
    func radix(_ r: Int, len: Int, left: Bool = true) -> String {
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

//MARK: FileManager
public extension FileManager {
    static func deleteFolder(_ paths: String..., dir: FileManager.SearchPathDirectory, in mask: FileManager.SearchPathDomainMask = .userDomainMask) {
        let folder = FileManager.default.urls(for: dir, in: mask).first!
        var cacheFolder = folder
        for i in paths {
            cacheFolder = cacheFolder.appendingPathComponent(i)
        }
        do {
            try FileManager.default.removeItem(at: cacheFolder)
        } catch let err {
            print(err)
        }
    }
}
