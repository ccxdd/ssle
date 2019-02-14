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
    public class var random: UIColor {
        return random(alpha: 1.0)
    }
    
    public class func random(alpha: CGFloat) -> UIColor {
        return UIColor(r:Int(arc4random_uniform(256)), g:Int(arc4random_uniform(256)), b:Int(arc4random_uniform(256)), a:alpha)
    }
    
    public convenience init(r: Int, g: Int, b: Int, a: CGFloat = 1.0) {
        assert(r >= 0 && r <= 255, "Invalid red component")
        assert(g >= 0 && g <= 255, "Invalid green component")
        assert(b >= 0 && b <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: a)
    }
    
    public convenience init(hex:Int, alpha: CGFloat = 1.0) {
        self.init(r:(hex >> 16) & 0xff, g:(hex >> 8) & 0xff, b:hex & 0xff, a: alpha)
    }
    
    public func alpha(_ a: CGFloat) -> UIColor {
        return withAlphaComponent(a)
    }
}
#endif
