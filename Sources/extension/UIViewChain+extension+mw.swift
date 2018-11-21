//
//  UIViewChain+extension+mw.swift
//  StandardLibraryExtension
//
//  Created by 陈晓东 on 2018/3/20.
//  Copyright © 2018年 陈晓东. All rights reserved.
//

import UIKit

public extension UIView {
    public func bg(_ c: UIColor?) -> Self {
        backgroundColor = c
        return self
    }
}

public extension UIButton {
    public func title(_ t: String?, state: UIControl.State = .normal) -> Self {
        setTitle(t, for: state)
        return self
    }
    
    public func titleColor(_ c: UIColor?, state: UIControl.State = .normal) -> Self {
        setTitleColor(c, for: state)
        return self
    }
    
    public func font(_ f: UIFont) -> Self {
        titleLabel?.font = f
        return self
    }
}

public extension UILabel {
    public func text(_ t: String?) -> Self {
        text = t
        return self
    }
    
    public func textColor(_ c: UIColor?) -> Self {
        textColor = c
        return self
    }
    
    public func font(_ f: UIFont) -> Self {
        font = f
        return self
    }
}
