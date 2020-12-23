//
//  NSAttributedString+extension+mw
//  StandardLibraryExtension
//
//  Created by 陈晓东 on 2017/9/18.
//  Copyright © 2017年 陈晓东. All rights reserved.
//

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

#if os(iOS)
typealias MWFont = UIFont
#elseif os(macOS)
typealias MWFont = NSFont
#endif

public enum AttributedStyle {
    /// ultraLight
    case ful(CGFloat)
    /// thin
    case ft(CGFloat)
    /// system
    case fs(CGFloat)
    /// boldSystem
    case fb(CGFloat)
    /// medium
    case fm(CGFloat)
    /// light
    case fl(CGFloat)
    /// semibold
    case fsb(CGFloat)
    /// heavy
    case fh(CGFloat)
    /// black
    case fbl(CGFloat)
    #if os(iOS)
    /// italicSystemFont
    case fi(CGFloat)
    #endif
    case fname(String, CGFloat)
    /// UIFont
    #if os(iOS)
    case font(UIFont)
    case c(UIColor)
    #elseif os(macOS)
    case font(NSFont)
    case c(NSColor)
    #endif
    case cHex(Int)
    /// baselineOffset
    case bl(CGFloat)
    /// lineSpace, paragraphSpacing, align
    case lps(CGFloat, CGFloat, NSTextAlignment)
    case uline(NSUnderlineStyle)
    case link(URL)
    /// 字间距
    case kern(CGFloat)
}

public extension NSMutableAttributedString {
    
    @discardableResult
    func addAttributed(_ styles: [AttributedStyle], range: NSRange? = nil) -> NSMutableAttributedString {
        guard length > 0 else { return self }
        addAttributes(attributesFrom(styles: styles), range: range ?? NSMakeRange(0, length))
        return self
    }
    
    @discardableResult
    func setAttributed(_ styles: [AttributedStyle], range: NSRange? = nil) -> NSMutableAttributedString {
        guard length > 0 else { return self }
        setAttributes(attributesFrom(styles: styles), range: range ?? NSMakeRange(0, length))
        return self
    }
    
    fileprivate func attributesFrom(styles: [AttributedStyle]) -> [NSAttributedString.Key: Any] {
        var attrs: [NSAttributedString.Key: Any] = [:]
        for s in styles {
            switch s {
            case .ful(let size):
                attrs[NSAttributedString.Key.font] = MWFont.systemFont(ofSize: size, weight: .ultraLight)
            case .ft(let size):
                attrs[NSAttributedString.Key.font] = MWFont.systemFont(ofSize: size, weight: .thin)
            case .fl(let size):
                attrs[NSAttributedString.Key.font] = MWFont.systemFont(ofSize: size, weight: .light)
            case .fs(let size):
                attrs[NSAttributedString.Key.font] = MWFont.systemFont(ofSize: size, weight: .regular)
            case .fm(let size):
                attrs[NSAttributedString.Key.font] = MWFont.systemFont(ofSize: size, weight: .medium)
            case .fsb(let size):
                attrs[NSAttributedString.Key.font] = MWFont.systemFont(ofSize: size, weight: .semibold)
            case .fb(let size):
                attrs[NSAttributedString.Key.font] = MWFont.systemFont(ofSize: size, weight: .bold)
            case .fh(let size):
                attrs[NSAttributedString.Key.font] = MWFont.systemFont(ofSize: size, weight: .heavy)
            case .fbl(let size):
                attrs[NSAttributedString.Key.font] = MWFont.systemFont(ofSize: size, weight: .black)
            #if os(iOS)
            case .fi(let size):
                attrs[NSAttributedString.Key.font] = MWFont.italicSystemFont(ofSize: size)
            #endif
            case .fname(let name, let size):
                attrs[NSAttributedString.Key.font] = MWFont(name: name, size: size)
            case .font(let font):
                attrs[NSAttributedString.Key.font] = font
            case .c(let c):
                attrs[NSAttributedString.Key.foregroundColor] = c
            case .cHex(let hex):
                #if os(iOS)
                attrs[NSAttributedString.Key.foregroundColor] = UIColor(hex: hex)
                #elseif os(macOS)
                attrs[NSAttributedString.Key.foregroundColor] = NSColor(hex: hex)
                #endif
            case .bl(let f):
                attrs[NSAttributedString.Key.baselineOffset] = NSNumber(value: Double(f))
            case .lps(let f, let f2, let align):
                let p = NSMutableParagraphStyle()
                p.lineSpacing = f
                p.paragraphSpacing = f2
                p.alignment = align
                attrs[NSAttributedString.Key.paragraphStyle] = p
            case .uline(let s):
                attrs[NSAttributedString.Key.underlineStyle] = s.rawValue
            case .link(let u):
                attrs[NSAttributedString.Key.link] = u
            case .kern(let len):
                attrs[NSAttributedString.Key.kern] = len
            }
        }
        return attrs
    }
    
    @discardableResult
    func prefix(_ str: String, _ styles: [AttributedStyle] = []) -> Self {
        insert(str, at: 0, styles: styles)
        return self
    }
    
    @discardableResult
    func suffix(_ str: String, _ styles: [AttributedStyle] = []) -> Self {
        insert(str, at: length, styles: styles)
        return self
    }
    
    @discardableResult
    func insert(_ str: String, at: Int, styles: [AttributedStyle] = []) -> Self {
        guard str.count > 0 else { return self }
        let attrStr = str.attrStr.setAttributed(styles)
        insert(attrStr, at: at)
        return self
    }
    
    @discardableResult
    func insert(attrStr: NSAttributedString?, at: Int) -> Self {
        guard let attrStr = attrStr else { return self }
        insert(attrStr, at: at)
        return self
    }
    
    @discardableResult
    func find(_ str: String, styles: [AttributedStyle] = []) -> Self {
        guard str.count > 0 else { return self }
        let range = (string as NSString).range(of: str)
        guard range.length > 0 else { return self }
        setAttributed(styles, range: range)
        return self
    }
    
    @discardableResult
    func replace(source: String, target: String, styles: [AttributedStyle] = []) -> Self {
        guard source.count > 0 else { return self }
        let content = string
        var range = (content as NSString).range(of: source, range: NSRange(location: 0, length: content.count))
        while range.length > 0 {
            if styles.count > 0 {
                replaceCharacters(in: range, with: target.attrStr.setAttributed(styles))
            } else {
                replaceCharacters(in: range, with: target)
            }
            range = (string as NSString).range(of: source, range: NSRange(location: range.location + target.count,
                                                                          length: content.count - range.location - range.length))
        }
        return self
    }
}
