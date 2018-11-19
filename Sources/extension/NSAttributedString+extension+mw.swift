//
//  NSAttributedString+extension+mw
//  StandardLibraryExtension
//
//  Created by 陈晓东 on 2017/9/18.
//  Copyright © 2017年 陈晓东. All rights reserved.
//

import UIKit

enum AttributedStyle {
    case fs(CGFloat) //system
    case fb(CGFloat) //boldSystem
    case c(UIColor)
    case cHex(Int)
}

extension NSMutableAttributedString {
    @discardableResult
    func setAttributed(styles: [AttributedStyle]) -> NSMutableAttributedString {
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
    func prefix(_ str: String, _ styles: [AttributedStyle] = []) -> NSMutableAttributedString {
        guard str.count > 0 else { return self }
        let attrStr = str.attrStr.setAttributed(styles: styles)
        insert(attrStr, at: 0)
        return self
    }
    
    @discardableResult
    func suffix(_ str: String, _ styles: [AttributedStyle] = []) -> NSMutableAttributedString {
        guard str.count > 0 else { return self }
        let attrStr = str.attrStr.setAttributed(styles: styles)
        append(attrStr)
        return self
    }
}
