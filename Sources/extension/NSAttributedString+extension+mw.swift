//
//  NSAttributedString+extension+mw
//  StandardLibraryExtension
//
//  Created by 陈晓东 on 2017/9/18.
//  Copyright © 2017年 陈晓东. All rights reserved.
//

import UIKit

public enum AttributedStyle {
    case fs(CGFloat) //system
    case fb(CGFloat) //boldSystem
    case c(UIColor)
    case cHex(Int)
}

extension NSMutableAttributedString {
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
            case .c(let c):
                attrs[NSAttributedString.Key.foregroundColor] = c
            case .cHex(let hex):
                attrs[NSAttributedString.Key.foregroundColor] = UIColor(hex: hex)
            }
        }
        setAttributes(attrs, range: NSMakeRange(0, length))
        return self
    }
    
    @discardableResult
    public func prefix(_ str: String, _ styles: [AttributedStyle] = []) -> NSMutableAttributedString {
        guard str.count > 0 else { return self }
        let attrStr = str.attrStr.setAttributed(styles: styles)
        insert(attrStr, at: 0)
        return self
    }
    
    @discardableResult
    public func suffix(_ str: String, _ styles: [AttributedStyle] = []) -> NSMutableAttributedString {
        guard str.count > 0 else { return self }
        let attrStr = str.attrStr.setAttributed(styles: styles)
        append(attrStr)
        return self
    }
    
    @discardableResult
    public func find(_ str: String, styles: [AttributedStyle] = []) -> NSMutableAttributedString {
        guard str.count > 0 else { return self }
        let range = (string as NSString).range(of: str)
        guard range.length > 0 else { return self }
        setAttributed(styles: styles, range: range)
        return self
    }
    
    @discardableResult
    public func replace(source: String, target: String, styles: [AttributedStyle] = []) -> NSMutableAttributedString {
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
