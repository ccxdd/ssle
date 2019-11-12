//
//  UIColor+extension+mw.swift
//  StandardLibraryExtension
//
//  Created by ccxdd on 2016/11/2.
//  Copyright © 2016年 ccxdd. All rights reserved.
//

#if os(iOS)
import UIKit

public extension UIColor {    
    class var random: UIColor {
        return random(alpha: 1.0)
    }
    
    class func random(alpha: CGFloat) -> UIColor {
        return UIColor(r:Int(arc4random_uniform(256)), g:Int(arc4random_uniform(256)), b:Int(arc4random_uniform(256)), a:alpha)
    }
    
    convenience init(r: Int, g: Int, b: Int, a: CGFloat = 1.0) {
        assert(r >= 0 && r <= 255, "Invalid red component")
        assert(g >= 0 && g <= 255, "Invalid green component")
        assert(b >= 0 && b <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: a)
    }
    
    convenience init(hex:Int, alpha: CGFloat = 1.0) {
        self.init(r:(hex >> 16) & 0xff, g:(hex >> 8) & 0xff, b:hex & 0xff, a: alpha)
    }
    
    func alpha(_ a: CGFloat) -> UIColor {
        return withAlphaComponent(a)
    }
}

public extension UIColor {
    enum CompatibleiOS13: Int {
        case text1, text2, text3, text4
        case bg1, bg2, bg3
        case group1, group2, group3
        case gray2, gray3, gray4, gray5, gray6
        case placeholder
        case link
        case separator, opaqueSeparator
        case fill1, fill2, fill3, fill4
    }
    
    static func compatible(c: CompatibleiOS13, light: UIColor) -> UIColor {
        if #available(iOS 13.0, *) {
            switch c {
            case .bg1:
                return .systemBackground
            case .bg2:
                return .secondarySystemBackground
            case .bg3:
                return .tertiarySystemBackground
            case .group1:
                return .systemGroupedBackground
            case .group2:
                return .secondarySystemGroupedBackground
            case .group3:
                return .tertiarySystemGroupedBackground
            case .text1:
                return .label
            case .text2:
                return .secondaryLabel
            case .text3:
                return .tertiaryLabel
            case .text4:
                return .quaternaryLabel
            case .gray2:
                return .systemGray2
            case .gray3:
                return .systemGray3
            case .gray4:
                return .systemGray4
            case .gray5:
                return .systemGray5
            case .gray6:
                return .systemGray6
            case .placeholder:
                return .placeholderText
            case .link:
                return .link
            case .separator:
                return .separator
            case .opaqueSeparator:
                return .opaqueSeparator
            case .fill1:
                return .systemFill
            case .fill2:
                return .secondarySystemFill
            case .fill3:
                return .tertiarySystemFill
            case .fill4:
                return .quaternarySystemFill
            }
        } else {
            return light
        }
    }
}
#endif
