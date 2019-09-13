//
//  UIViewChain+extension+mw.swift
//  StandardLibraryExtension
//
//  Created by 陈晓东 on 2018/3/20.
//  Copyright © 2018年 陈晓东. All rights reserved.
//

#if os(iOS)
import UIKit

public extension UIView {
    @discardableResult
    func bg(_ c: UIColor?) -> Self {
        backgroundColor = c
        return self
    }
    
    @discardableResult
    func corner(radius: CGFloat) -> Self {
        cornerRadius = radius
        return self
    }
    
    @discardableResult
    func border(color: UIColor?, w: CGFloat) -> Self {
        layer.borderColor = color?.cgColor
        layer.borderWidth = w
        return self
    }
}

public extension UIButton {
    @discardableResult
    func title(_ t: String?, state: UIControl.State = .normal) -> Self {
        setTitle(t, for: state)
        return self
    }
    
    @discardableResult
    func titleColor(_ c: UIColor?, state: UIControl.State = .normal) -> Self {
        setTitleColor(c, for: state)
        return self
    }
    
    @discardableResult
    func tintColor(_ c: UIColor?) -> Self {
        tintColor = c
        return self
    }
    
    @discardableResult
    func font(_ f: UIFont) -> Self {
        titleLabel?.font = f
        return self
    }
    
    @discardableResult
    func img(_ i: UIImage?, state: UIControl.State = .normal) -> Self {
        setImage(i, for: state)
        return self
    }
    
    @discardableResult
    func bgImg(_ i: UIImage?, state: UIControl.State = .normal) -> Self {
        setBackgroundImage(i, for: state)
        return self
    }
}

public extension UILabel {
    @discardableResult
    func text(_ t: String?) -> Self {
        text = t
        return self
    }
    
    @discardableResult
    func attributedText(_ t: NSAttributedString?) -> Self {
        attributedText = t
        return self
    }
    
    @discardableResult
    func textColor(_ c: UIColor?) -> Self {
        textColor = c
        return self
    }
    
    @discardableResult
    func font(_ f: UIFont) -> Self {
        font = f
        return self
    }
    
    @discardableResult
    func align(_ a: NSTextAlignment) -> Self {
        textAlignment = a
        return self
    }
    
    @discardableResult
    func lines(_ l: Int) -> Self {
        numberOfLines = l
        return self
    }
}

public extension UITextField {
    @discardableResult
    func borderStyle(_ s: UITextField.BorderStyle) -> Self {
        borderStyle = s
        return self
    }
    
    @discardableResult
    func placeholder(_ t: String?) -> Self {
        placeholder = t
        return self
    }
}
#endif
