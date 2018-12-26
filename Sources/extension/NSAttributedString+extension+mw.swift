//
//  NSAttributedString+extension+mw
//  StandardLibraryExtension
//
//  Created by 陈晓东 on 2017/9/18.
//  Copyright © 2017年 陈晓东. All rights reserved.
//

import UIKit

public enum AttributedStyle {
    /// system
    case fs(CGFloat)
    /// boldSystem
    case fb(CGFloat)
    /// italicSystemFont
    case fi(CGFloat)
    case fname(String, CGFloat)
    /// UIFont
    case font(UIFont)
    case c(UIColor)
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
    public func setAttributed(styles: [AttributedStyle], range: NSRange? = nil) -> NSMutableAttributedString {
        guard length > 0 else { return self }
        var attrs: [NSAttributedString.Key: Any] = [:]
        for s in styles {
            switch s {
            case .fb(let size):
                attrs[NSAttributedString.Key.font] = UIFont.boldSystemFont(ofSize: size)
            case .fs(let size):
                attrs[NSAttributedString.Key.font] = UIFont.systemFont(ofSize: size)
            case .fi(let size):
                attrs[NSAttributedString.Key.font] = UIFont.italicSystemFont(ofSize: size)
            case .fname(let name, let size):
                attrs[NSAttributedString.Key.font] = UIFont(name: name, size: size)
            case .font(let font):
                attrs[NSAttributedString.Key.font] = font
            case .c(let c):
                attrs[NSAttributedString.Key.foregroundColor] = c
            case .cHex(let hex):
                attrs[NSAttributedString.Key.foregroundColor] = UIColor(hex: hex)
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
        setAttributes(attrs, range: range ?? NSMakeRange(0, length))
        return self
    }
    
    @discardableResult
    public func prefix(_ str: String, _ styles: [AttributedStyle] = []) -> Self {
        insert(str, at: 0, styles: styles)
        return self
    }
    
    @discardableResult
    public func suffix(_ str: String, _ styles: [AttributedStyle] = []) -> Self {
        insert(str, at: length, styles: styles)
        return self
    }
    
    @discardableResult
    func insert(_ str: String, at: Int, styles: [AttributedStyle] = []) -> Self {
        guard str.count > 0 else { return self }
        let attrStr = str.attrStr.setAttributed(styles: styles)
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
    public func find(_ str: String, styles: [AttributedStyle] = []) -> Self {
        guard str.count > 0 else { return self }
        let range = (string as NSString).range(of: str)
        guard range.length > 0 else { return self }
        setAttributed(styles: styles, range: range)
        return self
    }
    
    @discardableResult
    public func replace(source: String, target: String, styles: [AttributedStyle] = []) -> Self {
        guard source.count > 0 else { return self }
        let content = string
        var range = (content as NSString).range(of: source, range: NSRange(location: 0, length: content.count))
        while range.length > 0 {
            if styles.count > 0 {
                replaceCharacters(in: range, with: target.attrStr.setAttributed(styles: styles))
            } else {
                replaceCharacters(in: range, with: target)
            }
            range = (string as NSString).range(of: source, range: NSRange(location: range.location + target.count,
                                                                          length: content.count - range.location - range.length))
        }
        return self
    }
}
