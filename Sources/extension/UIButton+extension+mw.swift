//
//  UIButton+extension+mw.swift
//  StandardLibraryExtension
//
//  Created by 陈晓东 on 2017/4/21.
//  Copyright © 2017年 陈晓东. All rights reserved.
//

import UIKit

private var buttonAdditionKey: Void?

final class ButtonAddition {
    var enabledFields: [UITextField]? = []
    fileprivate var enabledConditionClosure: (() -> Bool)?
    
    func enabledCondition(_ c: @escaping () -> Bool) {
        enabledConditionClosure = c
    }
}

extension UIButton {
    
    @IBOutlet var enabledChangeFields: [UITextField]? {
        set {
            addition.enabledFields = newValue
        }
        get {
            return addition.enabledFields
        }
    }
    
    fileprivate var addition: ButtonAddition {
        guard let a = objc_getAssociatedObject(self, &buttonAdditionKey) as? ButtonAddition else {
            let addition = ButtonAddition()
            objc_setAssociatedObject(self, &buttonAdditionKey, addition, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return addition
        }
        return a
    }
    
    func refreshEnabled() {
        guard let fields = enabledChangeFields else { return }
        let discontentArr = fields.filter { !$0.inputValid && $0.isHidden == false && $0.superview?.isHidden == false }
        isEnabled = discontentArr.isEmpty && (addition.enabledConditionClosure?() ?? true)
    }
}
