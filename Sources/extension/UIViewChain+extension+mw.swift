//
//  UIViewChain+extension+mw.swift
//  StandardLibraryExtension
//
//  Created by 陈晓东 on 2018/3/20.
//  Copyright © 2018年 陈晓东. All rights reserved.
//

import UIKit

extension UIView {
    func bg(_ c: UIColor?) -> Self {
        backgroundColor = c
        return self
    }
}

extension UIButton {
    func title(_ t: String?, state: UIControl.State = .normal) -> Self {
        setTitle(t, for: state)
        return self
    }
    
    func titleColor(_ c: UIColor?, state: UIControl.State = .normal) -> Self {
        setTitleColor(c, for: state)
        return self
    }
    
    func font(_ f: UIFont) -> Self {
        titleLabel?.font = f
        return self
    }
}

extension UILabel {
    func text(_ t: String?) -> Self {
        text = t
        return self
    }
    
    func textColor(_ c: UIColor?) -> Self {
        textColor = c
        return self
    }
    
    func font(_ f: UIFont) -> Self {
        font = f
        return self
    }
}
