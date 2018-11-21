//
//  UITextField+extension+mw.swift
//  StandardLibraryExtension
//
//  Created by 陈晓东 on 2017/4/21.
//  Copyright © 2017年 陈晓东. All rights reserved.
//

import UIKit

private var textFieldAdditionKey: Void?

public final class TextFieldAddition: NSObject, UITextFieldDelegate {
    var min: Int = 0
    var max: Int = 4096
    var decimal: Int = -1
    var didChangeClosure: ((String?) -> Void)?
    var inputCategory: UITextField.InputCategory = .none
    weak var weakField: UITextField!
    weak var enabledButton: UIButton?
    
    @objc fileprivate func textFieldDidChange() {
        switch inputCategory {
        case .decimal:
            guard let t = weakField?.text, t.isDecimal, !t.hasPrefix("."), !t.hasPrefix("00"), t.components(separatedBy: ".").count < 3 else {
                weakField.deleteBackward()
                didChangeClosure?(weakField.text)
                break
            }
            if t.count == 2, t.hasPrefix("0") {
                weakField.text = t.last?.description
            }
            guard checkLengthCondition() else {
                weakField.deleteBackward()
                return
            }
            didChangeClosure?(t)
        case .digit:
            guard let t = weakField.text, t.isInt else {
                weakField.deleteBackward()
                didChangeClosure?(weakField.text)
                break
            }
            if t.count == 2, t.hasPrefix("0") {
                weakField.text = t.last?.description
            }
            guard checkLengthCondition() else {
                weakField.deleteBackward()
                return
            }
            didChangeClosure?(t)
        default:
            didChangeClosure?(weakField.text)
        }
        enabledButton?.refreshEnabled()
    }
    
    func checkLengthCondition() -> Bool {
        switch inputCategory {
        case .decimal:
            if let len = weakField.text?.decimalNum, decimal > -1 {
                return len <= decimal
            } else {
                return true
            }
        case .digit:
            if let len = weakField.text?.count, max > 0 {
                return len <= max
            } else {
                return true
            }
        default: return true
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension UITextField {
    public enum InputCategory {
        case none, decimal, digit
    }
    
    public var addition: TextFieldAddition {
        guard let addition = objc_getAssociatedObject(self, &textFieldAdditionKey) as? TextFieldAddition else {
            let addition = TextFieldAddition()
            addition.weakField = self
            delegate = addition
            NotificationCenter.default.addObserver(addition, selector: #selector(addition.textFieldDidChange),
                                                   name: UITextField.textDidChangeNotification, object: nil)
            objc_setAssociatedObject(self, &textFieldAdditionKey, addition, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return addition
        }
        return addition
    }
    
    @IBOutlet public var enabledButton: UIButton? {
        set {
            addition.enabledButton = newValue
        }
        get {
            return addition.enabledButton
        }
    }
    
    @IBAction public func showPwd(_ sender: UIButton) {
        isSecureTextEntry = !isSecureTextEntry
        sender.isSelected = !sender.isSelected
    }
    
    @IBInspectable public var min: Int {
        get {
            return addition.min
        }
        set {
            addition.min = newValue
        }
    }
    
    @IBInspectable public var max: Int {
        get {
            return addition.max
        }
        set {
            addition.max = newValue
        }
    }
    
    @IBInspectable public var decimal: Int {
        get {
            return addition.decimal
        }
        set {
            addition.decimal = newValue
        }
    }
    
    public var textLength: Int {
        return text?.count ?? 0
    }
    
    public var inputValid: Bool {
        switch addition.inputCategory {
        case .none:
            return textLength > 0 && textLength >= min && textLength <= max
        default:
            return (text?.tF ?? 0) > 0
        }
    }
    
    public func didChange(_ c: InputCategory = .none, closure: @escaping (String?) -> Void) {
        addition.inputCategory = c
        addition.didChangeClosure = closure
        switch c {
        case .decimal:
            addition.weakField?.keyboardType = .decimalPad
        case .digit:
            addition.weakField?.keyboardType = .numberPad
        default: break
        }
    }
}
